import json

import asyncpg
from testcontainers.postgres import PostgresContainer
import pytest

from .lib import create_db_with_users
from server.lib import database, logger

logger.configure_logger(no_stdout=True)
pytest_plugins = ("pytest_asyncio",)


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

        test_client = await create_db_with_users(pg, users, monkeypatch)
        await test_client.set_type_codec(
            "json", encoder=json.dumps, decoder=json.loads, schema="pg_catalog"
        )

        async with test_client.transaction():
            # minimal database
            await test_client.execute(
                """
                CREATE TABLE machines (
                    id SERIAL,
                    username TEXT,
                    name TEXT,
                    machine_type INTEGER,
                    reflector JSON,

                    plugboard_enabled BOOLEAN,
                    plugboard_config JSON ARRAY[10],

                    character_pointer INTEGER,
                    character_history JSON ARRAY[140],

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
                        machine,
                        u["username"],
                        -1,
                    )

        # launch connection
        db = database.get_database()
        await db.connect()

        # pointer and save test
        pointer = await db._get_history_pointer_position(test_client, user, machine)
        assert pointer == -1

        test_pairs = [["a", "b"], ["w", "a"], ["g", "f"], ["b", "q"]]
        await db.save_keyboard_pair(user, machine, *test_pairs[0])
        pointer = await db._get_history_pointer_position(test_client, user, machine)
        assert pointer == 0

        # save to multiples
        async with test_client.transaction():
            for pair in test_pairs[1:]:
                await db.save_keyboard_pair(
                    user,
                    machine,
                    *pair,
                )

            await db.save_keyboard_pair(users[1]["username"], machines[3], "a", "c")

        pointer = await db._get_history_pointer_position(test_client, user, machine)
        assert pointer == 3

        # other state checks
        other_machine_ptr = await db._get_history_pointer_position(
            test_client, user, machines[3]
        )
        assert other_machine_ptr == -1

        other_user_ptr = await db._get_history_pointer_position(
            test_client, users[1]["username"], machines[3]
        )
        assert other_user_ptr == 0

        # test cycle of pointer
        async with test_client.transaction():
            for i in range(140):
                await db.save_keyboard_pair(user, machines[3], "x", "y")

                pointer = await db._get_history_pointer_position(
                    test_client, user, machines[3]
                )
                assert pointer == i

        # pointer overflow occurs here
        await db.save_keyboard_pair(user, machines[3], "x", "y")
        pointer = await db._get_history_pointer_position(test_client, user, machines[3])
        assert pointer == 0

        # test getting characters
        chars = await db.get_key_pairs(user, machines[3])
        assert chars == [["x", "y"] for _ in range(140)]

        chars = await db.get_key_pairs(user, machine)
        test_pairs.reverse()
        assert chars == test_pairs

        # test with no characters inserted
        chars = await db.get_key_pairs(user, machines[2])
        assert chars == []

        # test getting lastly inserted characters with pointer overflow
        expected_arr = (
            [["l", "h"], ["r", "s"], ["v", "t"]]
            + [["r", "s"] for _ in range(136)]
            + [["o", "p"]]
        )

        async with test_client.transaction():
            for i in range(70):
                await db.save_keyboard_pair(users[1]["username"], machines[1], "r", "s")
            await db.save_keyboard_pair(users[1]["username"], machines[1], "u", "i")

            # should be the 140th element on pointer 70:
            await db.save_keyboard_pair(users[1]["username"], machines[1], "o", "p")
            for i in range(136):
                await db.save_keyboard_pair(users[1]["username"], machines[1], "r", "s")

            await db.save_keyboard_pair(users[1]["username"], machines[1], "v", "t")
            await db.save_keyboard_pair(users[1]["username"], machines[1], "r", "s")
            await db.save_keyboard_pair(users[1]["username"], machines[1], "l", "h")

        pointer = await db._get_history_pointer_position(
            test_client, users[1]["username"], machines[1]
        )
        assert pointer == 70

        chars = await db.get_key_pairs(users[1]["username"], machines[1])
        assert chars == expected_arr

        # test with adding invalid inputs
        with pytest.raises(Exception):
            await db.save_keyboard_pair(user, machine, *["o", "+"])

        with pytest.raises(Exception):
            await db.save_keyboard_pair(user, machine, *["", "i"])

        with pytest.raises(Exception):
            await db.save_keyboard_pair(user, machine, *["p", "long"])

        # nothing should change after invalid inputs
        pointer = await db._get_history_pointer_position(
            test_client, users[1]["username"], machines[1]
        )
        assert pointer == 70

        chars = await db.get_key_pairs(users[1]["username"], machines[1])
        assert chars == expected_arr

        # clean up
        await db.disconnect()
        await test_client.close()


@pytest.mark.asyncio
async def test_postgres_plugboard_configuration(monkeypatch):
    # setup
    with PostgresContainer("postgres:16-alpine") as pg:
        users = [
            {"username": "user1", "password": "pass1"},
            {"username": "user2", "password": "pass2"},
        ]
        machines = [3596, 2375, 9465, 5767, 8451]

        user = users[0]["username"]
        machine = machines[0]

        test_client = await create_db_with_users(pg, users, monkeypatch)
        await test_client.set_type_codec(
            "json", encoder=json.dumps, decoder=json.loads, schema="pg_catalog"
        )

        async with test_client.transaction():
            # minimal database
            await test_client.execute(
                """
                CREATE TABLE machines (
                    id SERIAL,
                    username TEXT,
                    name TEXT,
                    machine_type INTEGER,
                    reflector JSON,

                    plugboard_enabled BOOLEAN,
                    plugboard_config JSON ARRAY[10],

                    character_pointer INTEGER,
                    character_history JSON ARRAY[140],

                    PRIMARY KEY (id, username),
                    CHECK (array_length(plugboard_config, 1) <= 10)
                )
                """
            )

            for u in users:
                for machine in machines:
                    await test_client.execute(
                        """
                        INSERT INTO machines(id, username, plugboard_config)
                        VALUES (
                            $1, 
                            $2, 
                            ARRAY[]::JSON[]
                        )
                        """,
                        machine,
                        u["username"],
                    )

        db = database.get_database()
        await db.connect()

        # insert pairs and read
        test_pairs = [["a", "b"], ["w", "g"], ["l", "h"]]
        for pair in test_pairs:
            await db.save_plugboard(user, machine, *pair)

        result = await db.get_plugboards(user, machine)
        for item in result:
            assert set(item) in [set(x) for x in test_pairs]

        # test length
        pair_number = await db._get_plugboard_count(user, machine)
        assert len(test_pairs) == pair_number

        # insert with pair exists
        with pytest.raises(Exception):
            await db.save_plugboard(user, machine, *test_pairs[0])

        # insert with one letter exists
        with pytest.raises(Exception):
            await db.save_plugboard(user, machine, *["k", "w"])

        # insert no latter
        with pytest.raises(Exception):
            await db.save_plugboard(user, machine, *["o", "+"])

        # insert nothing
        with pytest.raises(Exception):
            await db.save_plugboard(user, machine, *["", "i"])

        # insert too many
        with pytest.raises(Exception):
            await db.save_plugboard(user, machine, *["p", "long"])

        # ensure that nothing got inserted
        result = await db.get_plugboards(user, machine)
        for item in result:
            assert set(item) in [set(x) for x in test_pairs]

        pair_number = await db._get_plugboard_count(user, machine)
        assert len(test_pairs) == pair_number

        # raise exception on too many valid connections
        for pair in [
            ["x", "y"],
            ["q", "z"],
            ["j", "p"],
            ["c", "f"],
            ["v", "n"],
            ["e", "s"],
            ["r", "u"],
        ]:
            await db.save_plugboard(user, machine, *pair)

        pair_number = await db._get_plugboard_count(user, machine)
        assert pair_number == 10

        with pytest.raises(asyncpg.CheckViolationError):
            await db.save_plugboard(user, machine, *["m", "i"])

        # remove valid configurations
        for pair in test_pairs:
            await db.remove_plugboard(user, machine, *pair)

        pair_number = await db._get_plugboard_count(user, machine)
        assert pair_number == 7

        # exception on removing non-valid plug
        with pytest.raises(Exception):
            await db.remove_plugboard(user, machine, *test_pairs[0])

        pair_number = await db._get_plugboard_count(user, machine)
        assert pair_number == 7

        # remove all plugs
        all_plugs = await db.get_plugboards(user, machine)
        for pair in all_plugs:
            await db.remove_plugboard(user, machine, *pair)

        pair_number = await db._get_plugboard_count(user, machine)
        assert pair_number == 0

        # check empty plugboard request
        result = await db.get_plugboards(user, machine)
        assert result == []

        # clean up
        await db.disconnect()
        await test_client.close()
