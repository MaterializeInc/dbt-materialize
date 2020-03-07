from contextlib import contextmanager

from dbt.adapters.postgres import PostgresConnectionManager
from dbt.adapters.postgres import PostgresCredentials
from dbt.adapters.sql import SQLConnectionManager

from dataclasses import dataclass

@dataclass
class MaterializeCredentials(PostgresCredentials):
    @property
    def type(self):
        return 'materialize'

class MaterializeConnectionManager(PostgresConnectionManager):
    TYPE = 'materialize'

