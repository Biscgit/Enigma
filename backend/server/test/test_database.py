import asyncio
import json

import asyncpg
from testcontainers.postgres import PostgresContainer
import pytest

from server.lib import database, models, logger

logger.configure_logger(no_stdout=True)
pytest_plugins = ('pytest_asyncio',)


async def _create_db_with_users(pg: PostgresContainer, users, monkeypatch) -> asyncpg.Connection:
    # issue with testcontainers: wrong port mapping on postgres
    connection_url = pg.get_connection_url().replace("postgresql+psycopg2", "postgresql")
    port = connection_url.split(":")[-1].split('/')[0]

    # set env for to be tested db connection
    monkeypatch.setenv("DB_USER", pg.POSTGRES_USER)
    monkeypatch.setenv("DB_PASSWORD", pg.POSTGRES_PASSWORD)
    monkeypatch.setenv("DB_NAME", pg.POSTGRES_DB)
    monkeypatch.setenv("DB_PORT", port)
    monkeypatch.setenv("IP_POSTGRES", pg.get_container_host_ip())

    # prepare database
    test_client: asyncpg.Connection = await asyncpg.connect(connection_url)
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

    return test_client


@pytest.mark.asyncio
async def test_postgres_credentials(monkeypatch):
    # setup
    with PostgresContainer("postgres:16-alpine") as pg:
        users = [
            {"username": "user1", "password": "pass1"},
            {"username": "user2", "password": "pass2"},
        ]
        test_client = await _create_db_with_users(pg, users, monkeypatch)

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


@pytest.mark.asyncio
async def test_postgres_keypair_storage(monkeypatch):
    # setup
    with PostgresContainer("postgres:16-alpine") as pg:
        users = [
            {"username": "user1", "password": "pass1"},
            {"username": "user2", "password": "pass2"},
        ]
        machines = [3596, 2375, 9465, 5767, 8451]

        user = users[0]["username"]
        machine = machines[0]

        test_client = await _create_db_with_users(pg, users, monkeypatch)
        await test_client.set_type_codec(
            'json',
            encoder=json.dumps,
            decoder=json.loads,
            schema='pg_catalog'
        )

        async with test_client.transaction():
            # minimal database
            await test_client.execute(
                """
                CREATE TABLE machines (
                    id SERIAL,
                    username TEXT,
                
                    character_pointer INTEGER,
                    character_history JSON[140],
                    
                    PRIMARY KEY (id, username),
                    CHECK (array_length(character_history, 1) <= 140)
                )
                """
            )

            for u in users:
                for machine in machines:
                    await test_client.execute(
                        """
                        INSERT INTO machines(id, username, character_pointer, character_history)
                        VALUES (
                            $1, 
                            $2, 
                            $3,
                            ARRAY[]::JSON[]
                        )
                        """,
                        machine, u["username"], -1
                    )

        # launch connection
        db = database.get_database()
        await db.connect()

        # pointer and save test
        pointer = await db._get_history_pointer_position(test_client, user, machine)
        assert pointer == -1

        test_pairs = [['a', 'b'], ['w', 'a'], ['g', 'f'], ['b', 'q']]
        await db.save_keyboard_pair(user, machine, *test_pairs[0])
        pointer = await db._get_history_pointer_position(test_client, user, machine)
        assert pointer == 0

        # save to multiples
        async with test_client.transaction():
            for pair in test_pairs[1:]:
                await db.save_keyboard_pair(
                    user, machine, *pair,
                )

            await db.save_keyboard_pair(
                users[1]["username"], machines[3], 'a', 'c'
            )

        pointer = await db._get_history_pointer_position(test_client, user, machine)
        assert pointer == 3

        # other state checks
        other_machine_ptr = await db._get_history_pointer_position(test_client, user, machines[3])
        assert other_machine_ptr == -1

        other_user_ptr = await db._get_history_pointer_position(test_client, users[1]["username"], machines[3])
        assert other_user_ptr == 0

        # test cycle of pointer
        async with test_client.transaction():
            for i in range(140):
                await db.save_keyboard_pair(user, machines[3], 'x', 'y')

                pointer = await db._get_history_pointer_position(test_client, user, machines[3])
                assert pointer == i

        # pointer overflow occurs here
        await db.save_keyboard_pair(user, machines[3], 'x', 'y')
        pointer = await db._get_history_pointer_position(test_client, user, machines[3])
        assert pointer == 0

        # test getting characters
        chars = await db.get_key_pairs(user, machines[3])
        assert chars == [['x', 'y'] for _ in range(140)]

        chars = await db.get_key_pairs(user, machine)
        test_pairs.reverse()
        assert chars == test_pairs

        # test with no characters inserted
        chars = await db.get_key_pairs(user, machines[2])
        assert chars == []

        # test getting lastly inserted characters with pointer overflow
        expected_arr = [['l', 'h'], ['r', 's'], ['v', 't']] + [['r', 's'] for _ in range(136)] + [['o', 'p']]

        async with test_client.transaction():
            for i in range(70):
                await db.save_keyboard_pair(users[1]["username"], machines[1], 'r', 's')
            await db.save_keyboard_pair(users[1]["username"], machines[1], "u", "i")

            # should be the 140th element on pointer 70:
            await db.save_keyboard_pair(users[1]["username"], machines[1], "o", "p")
            for i in range(136):
                await db.save_keyboard_pair(users[1]["username"], machines[1], 'r', 's')

            await db.save_keyboard_pair(users[1]["username"], machines[1], "v", "t")
            await db.save_keyboard_pair(users[1]["username"], machines[1], "r", "s")
            await db.save_keyboard_pair(users[1]["username"], machines[1], "l", "h")

        pointer = await db._get_history_pointer_position(test_client, users[1]["username"], machines[1])
        assert pointer == 70

        chars = await db.get_key_pairs(users[1]["username"], machines[1])
        assert chars == expected_arr
