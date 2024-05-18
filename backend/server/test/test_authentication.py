import fastapi
import pytest
from testcontainers.postgres import PostgresContainer

from .lib import create_db_with_users
from server.lib import database, models, logger
from server.lib.routes import authentication as routes

logger.configure_logger(no_stdout=True)
pytest_plugins = ('pytest_asyncio',)


def test_check_auth_exits():
    # setup
    token = "HELLO"
    user = "USER"
    routes.current_auth = {token: user}

    # test
    returned_user = routes.check_auth(token)

    # check
    assert user == returned_user


def test_check_auth_not_exists():
    # setup
    token = "HELLO"
    user = "USER"
    routes.current_auth = {}

    # test
    with pytest.raises(fastapi.HTTPException):
        _ = routes.check_auth(token)


def test_check_auth_incorrect():
    # setup
    token = "HELLO"
    user = "USER"
    routes.current_auth = {token: "OTHER_USER"}

    # test
    returned_user = routes.check_auth(token)

    # check
    assert user != returned_user


@pytest.mark.asyncio
async def test_postgres_credentials(monkeypatch):
    # setup
    with PostgresContainer("postgres:16-alpine") as pg:
        users = [
            {"username": "user1", "password": "pass1"},
            {"username": "user2", "password": "pass2"},
        ]
        test_client = await create_db_with_users(pg, users, monkeypatch)

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

        await test_client.close()

