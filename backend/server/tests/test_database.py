import asyncpg
from testcontainers.postgres import PostgresContainer
import pytest

from server.lib import database, models

pytest_plugins = ('pytest_asyncio',)


@pytest.mark.asyncio
async def test_postgres_credentials(monkeypatch):
    # setup
    with PostgresContainer(
            "postgres:16-alpine",
            driver=None
    ) as pg:
        # issue with testcontainers: wrong port mapping on postgres
        connection_url = pg.get_connection_url()
        port = connection_url.split(":")[-1].split('/')[0]

        # set env for to be tested db connection
        monkeypatch.setenv("DB_USER", pg.username)
        monkeypatch.setenv("DB_PASSWORD", pg.password)
        monkeypatch.setenv("DB_NAME", pg.dbname)
        monkeypatch.setenv("DB_PORT", port)
        monkeypatch.setenv("IP_POSTGRES", pg.get_container_host_ip())

        # prepare database
        test_client: asyncpg.Connection = await asyncpg.connect(pg.get_connection_url())
        users = [
            {"username": "user1", "password": "pass1"},
            {"username": "user2", "password": "pass2"},
        ]
        async with test_client.transaction():
            await test_client.execute(
                """
                CREATE TABLE IF NOT EXISTS users (
                    username TEXT PRIMARY KEY,
                    password TEXT
                )
                """
            )

            for user in users:
                await test_client.execute(
                    """
                    INSERT INTO users(username, password)
                    SELECT $1, $2;
                    """,
                    user["username"], user["password"]
                )

        # check hashing of passwords by choosing one random
        password: str = await test_client.fetchval(
            """
            SELECT password
            FROM users
            ORDER BY RANDOM() LIMIT 1
            """
        )
        assert not password.startswith("$2a$06$")

        # launch connection
        db = database.get_database()
        await db.connect()

        # ensure one connection
        with pytest.raises(Exception):
            await db.connect()

        # check correct username
        result: bool = await db.check_login(models.LoginForm.model_construct(**users[0]))
        assert result is True

        result: bool = await db.check_login(models.LoginForm.model_construct(**users[1]))
        assert result is True

        # check wrong password
        result: bool = await db.check_login(models.LoginForm.model_construct(
            username=users[0]["username"],
            password="RANDOM PASSWORD",
        ))
        assert result is False

        # check password of another user
        result: bool = await db.check_login(models.LoginForm.model_construct(
            username=users[0]["username"],
            password=users[1]["password"],
        ))
        assert result is False

        # clean up
        await db.disconnect()
        with pytest.raises(Exception):
            await db.disconnect()
