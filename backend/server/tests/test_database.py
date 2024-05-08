import asyncio
import logging
import os

from testcontainers.postgres import PostgresContainer
import pytest

from server.lib import database

pytest_plugins = ('pytest_asyncio',)


@pytest.mark.asyncio
async def testcontainer_postgres(monkeypatch):
    # setup
    with PostgresContainer(
            "postgres:16-alpine",
            driver=None
    ) as pg:
        # issue with testcontainers: wrong port mapping on postgres
        port = pg.get_connection_url().split(":")[-1].split('/')[0]

        # set env for db connection
        monkeypatch.setenv("DB_USER", pg.username)
        monkeypatch.setenv("DB_PASSWORD", pg.password)
        monkeypatch.setenv("DB_NAME", pg.dbname)
        monkeypatch.setenv("DB_PORT", port)
        monkeypatch.setenv("IP_POSTGRES", pg.get_container_host_ip())

        # launch connection
        db = database.get_database()
        await db.connect()

        # ensure one connection
        with pytest.raises(Exception):
            await db.connect()

        # clean up
        await db.disconnect()
        with pytest.raises(Exception):
            await db.disconnect()
