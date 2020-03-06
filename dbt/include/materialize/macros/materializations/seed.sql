{% macro materialize__load_csv_rows(model) %}

  {% set agate_table = model['agate_table'] %}
  {% set bindings = agate_table.rows %}
  {% set cols_sql %}
    {%- for i, column in enumerate(agate_table.column_names) -%}
      column{{i}} as {{column}}
      {%- if not loop.last%},{%- endif %}
    {% endfor %}
  {% endset %}

  {% set sql %}
    create materialized view {{ this.render(False) }} AS (
      select {{ cols_sql }} from (VALUES
      {% for row in bindings -%} 
        ({%- for column in agate_table.column_names -%}
            %s
            {%- if not loop.last%},{%- endif %}
        {%- endfor -%})
        {%- if not loop.last%},{%- endif %}
      {%- endfor %}         
      ) AS tbl
    );
  {% endset %}

  {% set _ = adapter.add_query(sql, bindings=bindings, abridge_sql_log=True) %}
  {{ return(sql) }}
{% endmacro %}

{% macro materialize__reset_csv_table(model, full_refresh, old_relation) %}
    {% if old_relation %}
        {{ adapter.drop_relation(old_relation) }}
    {% endif %}
    {% set sql = create_csv_table(model) %}
    {{ return(sql) }}
{% endmacro %}

{% materialization seed, adapter='materialize' %}

  {%- set identifier = model['alias'] -%}
  {%- set old_relation = adapter.get_relation(database=database, schema=schema, identifier=identifier) -%}
  {%- set csv_table = model["agate_table"] -%}

  {{ run_hooks(pre_hooks, inside_transaction=False) }}

  -- `BEGIN` happens here:
  {{ run_hooks(pre_hooks, inside_transaction=True) }}

  -- build model
  {% set status = 'CREATE' %}
  {% set num_rows = (csv_table.rows | length) %}
  {% set sql = load_csv_rows(model) %}

  {% call noop_statement('main', status ~ ' ' ~ num_rows) %}
    -- dbt seed --
    {{ sql }}
  {% endcall %}

  {{ run_hooks(post_hooks, inside_transaction=True) }}
  -- `COMMIT` happens here
  {{ adapter.commit() }}
  {{ run_hooks(post_hooks, inside_transaction=False) }}
{% endmaterialization %}
