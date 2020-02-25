from dbt.adapters.postgres import PostgresAdapter
from dbt.adapters.postgres import PostgresColumn
from dbt.adapters.materialize import MaterializeConnectionManager


class MaterializeAdapter(PostgresAdapter):
    ConnectionManager = MaterializeConnectionManager
    Column = PostgresColumn

    @classmethod
    def date_function(cls):
        return 'now()' 
