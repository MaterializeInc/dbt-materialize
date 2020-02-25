from dbt.adapters.sql import SQLAdapter
from dbt.adapters.materialize import MaterializeAdapterConnectionManager


class MaterializeAdapterAdapter(SQLAdapter):
    ConnectionManager = MaterializeAdapterConnectionManager
