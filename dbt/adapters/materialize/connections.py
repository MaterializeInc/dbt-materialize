from contextlib import contextmanager

from dbt.adapters.postgres import PostgresConnectionManager
from dbt.adapters.postgres import PostgresCredentials
from dbt.adapters.sql import SQLConnectionManager

MATERIALIZE_CREDENTIALS_CONTRACT = {
    'type': 'object',
    'additionalProperties': False,
    'properties': {
        'database': {
            'type': 'string',
        },
        'host': {
            'type': 'string',
        },
        'user': {
            'type': 'string',
        },
        'password': {
            'type': 'string',
        },
        'port': {
            'type': 'integer',
            'minimum': 0,
            'maximum': 65535,
        },
        'schema': {
            'type': 'string',
        },
        'search_path': {
            'type': 'string',
        },
        'keepalives_idle': {
            'type': 'integer',
        },
    },
    'required': ['database', 'host', 'user', 'password', 'port', 'schema']
}

class MaterializeCredentials(PostgresCredentials):
    SCHEMA = MATERIALIZE_CREDENTIALS_CONTRACT

    def __init__(self, *args, **kwargs):
        super(MaterializeCredentials, self).__init__(*args, **kwargs)

    @property
    def type(self):
        return 'materialize'

    def _connection_keys(self):
        return (
            'host', 'port', 'user', 'database', 'schema', 'method',
            'search_path')


class MaterializeConnectionManager(PostgresConnectionManager):
    DEFAULT_TCP_KEEPALIVE = 0  # 0 means to use the default value
    TYPE = 'materialize'


