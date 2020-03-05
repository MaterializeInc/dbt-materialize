from dbt.adapters.postgres import PostgresAdapter
from dbt.adapters.postgres import PostgresColumn
from dbt.adapters.materialize import MaterializeConnectionManager

MATERIALIZE_GET_COLUMNS_MACRO_NAME = 'materialize_get_columns'
MATERIALIZE_CONVERT_COLUMNS_MACRO_NAME = 'sql_convert_columns_in_relation'
MATERIALIZE_GET_FULL_VIEWS_MACRO_NAME = 'materialize_get_full_views'
MATERIALIZE_GET_SOURCES_MACRO_NAME = 'materialize_get_sources'

class MaterializeAdapter(PostgresAdapter):
    ConnectionManager = MaterializeConnectionManager
    Column = PostgresColumn

    @classmethod
    def date_function(cls):
        return 'now()'

    @classmethod
    def is_cancelable(cls):
        return False

    def get_columns_in_relation(self, relation):
        columns = self.execute_macro(
            MATERIALIZE_GET_COLUMNS_MACRO_NAME,
            kwargs={'relation': relation}
        )

        table = []
        for _field, _nullable, _type in columns:
           table.append((_field, _type))
 
        return self.execute_macro(
            MATERIALIZE_CONVERT_COLUMNS_MACRO_NAME,
            kwargs={'table': table}
        )

    def list_relations_without_caching(self, information_schema, schema):
        full_views = self.execute_macro(
            MATERIALIZE_GET_FULL_VIEWS_MACRO_NAME,
            kwargs={'schema': schema}
        )

        relations = []
        quote_policy = {
            'database': True,
            'schema': True,
            'identifier': True
        }
        for _view, _type, _queryable, _materialized  in full_views:
            if _type == 'USER' and _queryable == 't':
              dbt_type = 'table' if _materialized == 't' else 'view'
              relations.append(self.Relation.create(
                  database=database,
                  schema=schema,
                  identifier=_view,
                  quote_policy=quote_policy,
                  type=dbt_type
              ))

        sources = self.execute_macro(
            MATERIALIZE_GET_SOURCES_MACRO_NAME,
            kwargs={'schema': schema}
        )
        for _src in sources:
            relations.append(self.Relation.create(
                database=database,
                schema=schema,
                identifier=_src,
                quote_policy=quote_policy,
                type='table'
            ))
        return relations

    def check_schema_exists(self, database, schema):
        return schema in self.list_schemas(database)

    # jwills hacking to get stuff to work
    def _link_cached_relations(self, manifest):
        schemas = set()
        # only link executable nodes
        info_schema_name_map = self._get_cache_schemas(manifest,
                                                       exec_only=True)
        for db, schema in info_schema_name_map.search():
            self.verify_database(db.database)
            schemas.add(schema)
