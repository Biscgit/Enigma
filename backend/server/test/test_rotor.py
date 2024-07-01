import pytest
import json
from testcontainers.postgres import PostgresContainer
from pydantic import BaseModel

from .lib import create_db_with_users
from server.lib import database, logger
from server.lib.routes.key_input import encrypt

logger.configure_logger(no_stdout=True)
pytest_plugins = ("pytest_asyncio",)


@pytest.mark.asyncio
async def test_postgres_rotors_storage(monkeypatch):
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
                CREATE TABLE IF NOT EXISTS machines (
                    id SERIAL,
                    username TEXT,
                    name TEXT,
                    reflector JSON,
                    reflector_id TEXT,

                    number_rotors INTEGER,

                    character_pointer INTEGER,
                    character_history JSON ARRAY[140],

                    plugboard_enabled BOOLEAN,
                    plugboard_config JSON ARRAY[10],

                    PRIMARY KEY (id, username),
                    FOREIGN KEY (username) REFERENCES users(username),

                    UNIQUE (username, name),
                    CHECK (array_length(character_history, 1) <= 140),
                    CHECK (array_length(plugboard_config, 1) <= 10)
                );
                """
            )

            await test_client.execute(
                """
                CREATE TABLE IF NOT EXISTS rotors (
                    id SERIAL,
                    username TEXT,
                    machine_id SERIAL,
                    scramble_alphabet TEXT,
                    machine_type INTEGER,
                    letter_shift TEXT,
                    rotor_position TEXT,
                    offset_value INTEGER,

                    place INTEGER,
                    number INTEGER,
                    is_rotate BOOLEAN,

                    PRIMARY KEY (id),
                    FOREIGN KEY (machine_id, username) REFERENCES machines(id, username)
                );
                """
            )

        # launch connection
        db = database.get_database()
        await db.connect()

        for i in range(3):
            await db.switch_rotor("user1", 1, 1, i, 1)

        clear_text = "loremipsumdolorsitametconsetetursadipscingelitrseddiamnonumyeirmodtemporinviduntutlaboreetdoloremagnaaliquyameratseddiamvoluptuaatveroeosetaccusametjustoduodolorloremipsumdolorsitametconsetetursadipscingelitrseddiamnonumyeirmodtemporinviduntutlaboreetdoloremagnaaliquyameratseddiamvoluptuaatveroeosetaccusametjustoduodolorloremipsumdolorsitametconsetetursadipscingelitrseddiamnonumyeirmodtemporinviduntutlabore"
        encrypted_text = "azjkkvhkcqgvgkvdrgqsnplvtaymcllaywojjaajfuryxqvxbubhoiqcwiggdzbddczufdxnedjrzlcohlevqnkhqojmbxpxbdfrrdsmtgethfblqkximubeizoyxswpvdlafmdhlszdzhwxnxsatlnveaeezgkcnxinuifeitgksrrymexioyitqmifppqtupycfjzwssocqwonxfolyddbkoxxvsczexmnhvhkpfwirklbjmypdwtectphynfsxnpkxudtdckilkffkyndhvulvwlhhdsflvohdzspeiflgovwcndtfrtzfxpsshkyizpwokyeocwpwctlkkvjrpolkdefibpqkwwdvlunwhvyytdqnfchojwqiuuehabmwxxlpmycaikiivqdzxmpnwlkhq"
        rotor_end_state = [
            {
                "id": 58,
                "username": "user1",
                "machine_id": 1,
                "scramble_alphabet": "ekmflgdqvzntowyhxuspaibrcj",
                "machine_type": 1,
                "letter_shift": "y",
                "rotor_position": "u",
                "offset_value": 0,
                "place": 0,
                "number": 1,
                "is_rotate": True,
            },
            {
                "id": 60,
                "username": "user1",
                "machine_id": 1,
                "scramble_alphabet": "ekmflgdqvzntowyhxuspaibrcj",
                "machine_type": 1,
                "letter_shift": "y",
                "rotor_position": "r",
                "offset_value": 0,
                "place": 1,
                "number": 1,
                "is_rotate": False,
            },
            {
                "id": 59,
                "username": "user1",
                "machine_id": 1,
                "scramble_alphabet": "ekmflgdqvzntowyhxuspaibrcj",
                "machine_type": 1,
                "letter_shift": "y",
                "rotor_position": "b",
                "offset_value": 0,
                "place": 2,
                "number": 1,
                "is_rotate": True,
            },
        ]

        for clear_chr, enc_chr in zip(clear_text, encrypted_text):
            result = await encrypt("user1", 1, db, clear_chr)
            assert result == enc_chr

        rotor_ids = await db.get_rotors("user1", 1)
        for i in range(3):
            rotor_end_state[i]["id"] = rotor_ids[i]["id"]
            assert rotor_end_state[i] == await db.get_rotor("user1", rotor_ids[i]["id"])

        # clean up
        await db.disconnect()
        await test_client.close()
