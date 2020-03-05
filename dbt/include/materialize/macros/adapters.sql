{% macro materialize__create_table_as(temporary, relation, sql) -%}

  create materialized view if not exists {{ relation }}
  as (
    {{ sql }}
  );
{%- endmacro %}

{% macro materialize__create_schema(database_name, schema_name) -%}
  {% if database_name -%}
    {{ adapter.verify_database(database_name) }}
  {%- endif -%}
  {%- call statement('create_schema') -%}
    create schema if not exists {{ schema_name }}
  {%- endcall -%}
{% endmacro %}

{% macro materialize__drop_schema(database_name, schema_name) -%}
  {% if database_name -%}
    {{ adapter.verify_database(database_name) }}
  {%- endif -%}
  {%- call statement('drop_schema') -%}
    drop schema if exists {{ schema_name }} cascade
  {%- endcall -%}
{% endmacro %}

{% macro materialize__get_columns_in_relation(relation) -%}
  {% call statement('get_columns_in_relation', fetch_result=True) %}
      show columns from {{ relation.identifier }}
  {% endcall %}
  {% set table = load_result('get_columns_in_relation').table %}
  {{ return(sql_convert_columns_in_relation(table)) }}
{% endmacro %}


{% macro materialize__list_relations_without_caching(information_schema, schema) %}
  {% call statement('list_relations_without_caching', fetch_result=True) -%}
    select
      '{{ information_schema.database.lower() }}' as database,
      tablename as name,
      schemaname as schema,
      'table' as type
    from pg_tables
    where schemaname ilike '{{ schema }}'
    union all
    select
      '{{ information_schema.database.lower() }}' as database,
      viewname as name,
      schemaname as schema,
      'view' as type
    from pg_views
    where schemaname ilike '{{ schema }}'
  {% endcall %}
  {{ return(load_result('list_relations_without_caching').table) }}
{% endmacro %}

{% macro materialize__list_schemas(database) %}
  {% if database -%}
    {{ adapter.verify_database(database) }}
  {%- endif -%}
  {% call statement('list_schemas', fetch_result=True, auto_begin=False) %}
    show schemas from {{ database }}
  {% endcall %}
  {{ return(load_result('list_schemas').table) }}
{% endmacro %}

{% macro materialize__check_schema_exists(information_schema, schema) -%}
  {% if database -%}
    {{ adapter.verify_database(information_schema.database) }}
  {%- endif -%}
  {% call statement('check_schema_exists', fetch_result=True, auto_begin=False) %}
    show schemas;
  {% endcall %}
  {{ return(load_result('check_schema_exists').table) }}
{% endmacro %}


{% macro materialize__current_timestamp() -%}
  now()
{%- endmacro %}

{% macro materialize__snapshot_get_time() -%}
  {{ current_timestamp() }}::timestamp without time zone
{%- endmacro %}
