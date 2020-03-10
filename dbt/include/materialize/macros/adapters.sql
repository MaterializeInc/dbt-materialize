{% macro materialize__create_table_as(temporary, relation, sql) -%}

  create materialized view {{ relation }}
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

{% macro materialize__drop_relation(relation) -%}
  {% call statement('drop_relation', auto_begin=False) -%}
    drop view if exists {{ relation }} cascade
  {%- endcall %}
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

{% macro materialize__current_timestamp() -%}
  now()
{%- endmacro %}

{% macro materialize__snapshot_get_time() -%}
  {{ current_timestamp() }}::timestamp without time zone
{%- endmacro %}
