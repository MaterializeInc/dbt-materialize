from dbt.adapters.materialize.connections import MaterializeAdapterConnectionManager
from dbt.adapters.materialize.connections import MaterializeAdapterCredentials
from dbt.adapters.materialize.impl import MaterializeAdapterAdapter

from dbt.adapters.base import AdapterPlugin
from dbt.include import materialize


Plugin = AdapterPlugin(
    adapter=MaterializeAdapterAdapter,
    credentials=MaterializeAdapterCredentials,
    include_path=materialize.PACKAGE_PATH)
