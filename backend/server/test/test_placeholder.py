import asyncpg
from testcontainers.postgres import PostgresContainer
import pytest

from server.lib import database, models

pytest_plugins = ('pytest_asyncio',)


@pytest.mark.asyncio
async def test_postgres_credentials(monkeypatch):
    # setup
    with PostgresContainer("postgres:16-alpine") as pg:
        # issue with testcontainers: wrong port mapping on postgres
        connection_url = pg.get_connection_url()
        port = connection_url.split(":")[-1].split('/')[0]

        # set env for to be tested db connection
        monkeypatch.setenv("DB_USER", pg.POSTGRES_USER)
        monkeypatch.setenv("DB_PASSWORD", pg.POSTGRES_PASSWORD)
        monkeypatch.setenv("DB_NAME", pg.POSTGRES_DB)
        monkeypatch.setenv("DB_PORT", port)
        monkeypatch.setenv("IP_POSTGRES", pg.get_container_host_ip())

        # prepare database
        await asyncpg.connect(pg.get_connection_url())
