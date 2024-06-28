__all__ = ["get_database", "Database"]

import asyncio
import contextlib
import itertools
import json
import logging
import string
from os import environ

import asyncpg
import fastapi
import rustlib

from .models import LoginForm
from .rotor import Rotor


class Database:
    """Database interface"""

    char_max = 140
    instance: "Database" = None

    def __init__(self):
        self.pool: asyncpg.Pool | None = None

    @contextlib.asynccontextmanager
    async def fastapi_lifespan(self, app: fastapi.FastAPI):
        """Ensure clean startup and shutdown. Needs to be called before the start"""

        await self.connect()
        yield

        await self.disconnect()

    async def connect(self) -> None:
        logging.info("Connecting to database...")

        if self.pool is not None:
            raise Exception("Database connection is already established")

        for _ in range(6):
            try:
                conn: asyncpg.Pool = await asyncpg.create_pool(
                    user=environ.get("DB_USER"),
                    password=environ.get("DB_PASSWORD"),
                    database=environ.get("DB_NAME"),
                    host=environ.get("IP_POSTGRES"),
                    port=environ.get("DB_PORT"),
                )

            except (ConnectionRefusedError, asyncpg.exceptions.CannotConnectNowError):
                logging.info("Retrying to connect...")
                await asyncio.sleep(5)

            else:
                self.pool = conn

                async with self.pool.acquire() as c:
                    async with c.transaction():
                        version = await conn.fetchval("SELECT version()")

                logging.info(f"Successfully connected to database {version}")

                await self._initialize_db()
                await self._load_users()
                await self._load_machines()
                await self._load_rotors()
                return

        logging.critical("Failed to connect to database after 30 seconds")
        exit(1)

    async def _initialize_db(self) -> None:
        logging.info("Initializing database...")

        with open("./server/other/initialize.sql") as file:
            content = file.read()

            async with self.pool.acquire() as conn:
                async with conn.transaction():
                    # load module
                    await conn.execute("CREATE EXTENSION IF NOT EXISTS pgcrypto")

                    # fill db
                    for qry in content.split(";"):
                        if qry.strip():
                            await conn.execute(qry)

        logging.info("Successfully initialized database")

    async def _load_users(self) -> None:
        logging.info("Loading users from file...")
        with open("./server/users.json") as file:
            content = file.read()

        async with self.pool.acquire() as conn:
            async with conn.transaction():
                await conn.execute(
                    """
                    INSERT INTO users(username, password)
                    SELECT 
                        (data->>'username')::TEXT, 
                        crypt((data->>'password')::TEXT, gen_salt('bf'))
                    FROM json_array_elements($1::json) as data
                    ON CONFLICT (username) DO UPDATE
                    SET password = EXCLUDED.password;
                    """,
                    content,
                )

        logging.info("Successfully loaded users from file")

    async def _get_users(self) -> list[str]:
        """Returns a list of usernames"""
        async with self.pool.acquire() as conn:
            async with conn.transaction():
                result = await conn.fetch(
                    """
                    SELECT username
                    FROM  users
                    """
                )
                return [row["username"] for row in result]

    async def _load_machines(self) -> None:
        logging.info("Loading machines from file...")
        with open("./server/machines.json") as file:
            content = json.load(file)

        alphabet = string.ascii_lowercase
        for username in await self._get_users():
            for machine in content:
                reflectors = {}
                for k, reflector in machine["reflector"].items():
                    reflectors[k] = {}
                    for i, j in zip(reflector, alphabet):
                        reflectors[k][i.lower()] = j.lower()
                        reflectors[k][j.lower()] = i.lower()
                try:
                    await self.create_machine(
                        username,
                        # machine["machine_type"],
                        machine["name"],
                        reflectors,
                        True,
                        machine["number_rotors"],
                        list(machine["reflector"].keys())[0],
                        ignore_exist=True,
                    )
                except asyncpg.PostgresError:
                    logging.warning(f"Machine `{machine}` already exists!")

        logging.info("Successfully loaded machines from file")

    async def _load_rotors(self) -> None:
        logging.info("Loading rotors from file...")
        with open("./server/rotors.json") as file:
            content = json.load(file)

        for username in await self._get_users():
            for rotor in content:
                rotor["username"] = username
                rotor["machine_id"] = 0
                rotor["place"] = 0
                rotor["number"] = 0
                rotor["is_rotate"] = True
                rotor["offset_value"] = 0
                try:
                    await self.set_rotor(rotor)
                except asyncpg.PostgresError:
                    logging.warning(f"Rotor `{rotor}` already exists!")

        logging.info("Successfully loaded rotors from file")

    async def disconnect(self) -> None:
        if self.pool is None:
            raise Exception("There is no connection to close!")

        await self.pool.close()
        self.pool = None

        logging.info("Successfully disconnected from database")

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    async def check_login(self, form: LoginForm) -> bool:
        """Returns a bool for weather the credentials are valid"""
        async with self.pool.acquire() as conn:
            async with conn.transaction():
                result: bool = await conn.fetchval(
                    """
                    SELECT crypt($2, password) = password AS password_match 
                    FROM  users
                    WHERE username = $1;
                    """,
                    form.username,
                    form.password,
                )

                return result

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    async def create_machine(
        self,
        username: str,
        name: str,
        reflector: dict,
        plugboard: bool,
        number_rotors: int,
        reflector_id: str,
        ignore_exist: bool = False,
    ) -> int:
        """creates a new machine for a user if it does not exist"""
        id = len(await self.get_machines(username))
        async with self.pool.acquire() as conn:
            async with conn.transaction():
                await conn.execute(
                    f"""
                        INSERT INTO machines(id, username, name, reflector, reflector_id, character_pointer, character_history, plugboard_enabled, plugboard_config, number_rotors)
                        VALUES ($1, $2, $3, $4::JSON, $5, -1, ARRAY[]::JSON[], $6, ARRAY[]::JSON[], $7)
                        {'ON CONFLICT DO NOTHING' if ignore_exist else ''}
                    """,
                    id,
                    username,
                    name,
                    json.dumps(reflector),
                    reflector_id,
                    plugboard,
                    number_rotors,
                )
                logging.debug(f"Created machine {username}.{id} of type")
        return id

    async def get_machines(self, username: str) -> list:
        async with self.pool.acquire() as conn:
            async with conn.transaction():
                conn: asyncpg.Connection

                result = await conn.fetch(
                    """
                    SELECT id, name, number_rotors
                    FROM machines
                    WHERE username = $1
                    ORDER BY COALESCE(id, 0)
                    """,
                    username,
                )
                logging.debug(f"Get machines for {username}: {result}")
            return [dict(record) for record in result if record is not None]

    async def save_keyboard_pair(
        self, username: str, machine: int, clear: str, encrypted: str
    ) -> None:
        """saves a key pair into the database history"""
        async with self.pool.acquire() as conn:
            async with conn.transaction():
                conn: asyncpg.Connection

                if any(
                    e.lower() not in string.ascii_lowercase for e in [clear, encrypted]
                ):
                    raise Exception("One of the symbols cannot be inserted as history!")
                if any(len(e) != 1 for e in [clear, encrypted]):
                    raise Exception("One of the symbols is not a single character!")

                pointer = await self._get_history_pointer_position(
                    conn, username, machine
                )
                pointer = (pointer + 1) % Database.char_max

                # update the pointer and add character-pair in O(1) time
                await conn.execute(
                    f"""
                    UPDATE machines
                    SET character_history[{pointer}] = $4::json,
                        character_pointer = $3
                    WHERE username = $1 AND id = $2
                    """,
                    username,
                    machine,
                    pointer,
                    json.dumps([clear, encrypted]),
                )

                logging.info(f"Saved key-pair to database with index {pointer}")

    async def get_key_pairs(self, username: str, machine: int) -> list[list[str]]:
        """returns key-pairs in last inserted first order"""
        async with self.pool.acquire() as conn:
            async with conn.transaction():
                conn: asyncpg.Connection

                result = await conn.fetchval(
                    f"""
                    WITH indexed_history AS (
                        SELECT 
                            elem,
                            (character_pointer - index + 1 + {Database.char_max}) % {Database.char_max} AS shifted_index
                        FROM machines,
                        UNNEST(character_history) WITH ORDINALITY AS unnested(elem, index)
                        WHERE username = $1 AND id = $2
                    )
                    SELECT
                      ARRAY_AGG(elem ORDER BY shifted_index) AS sorted_array
                    FROM
                      indexed_history
                    """,
                    username,
                    machine,
                )

                logging.info(
                    f"Fetched key-pairs for {username}.{machine}: {str(result)[:80]}"
                )
                return [json.loads(pair) for pair in result or []]

    @staticmethod
    async def _get_history_pointer_position(
        conn: asyncpg.Connection, username: str, machine: int
    ) -> int:
        """Returns the point position of the current history. The value is between 0-139 or -1 if not set"""
        try:
            return int(
                await conn.fetchval(
                    """
                SELECT character_pointer
                FROM machines
                WHERE username = $1 AND id = $2
                """,
                    username,
                    machine,
                )
            )

        except TypeError:
            logging.error(f"Machine {username}.{machine} does not exist!")
            raise

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    async def save_plugboard(
        self, username: str, machine: int, key_1: str, key_2: str
    ) -> None:
        """saves a plugboard configuration to a machine"""
        try:
            async with self.pool.acquire() as conn:
                async with conn.transaction():
                    conn: asyncpg.Connection
                    plugboard = [key_1.lower(), key_2.lower()]

                    # execute a check before inserting
                    current_plugs = await self.get_plugboards(username, machine)
                    flatten_plugs = set(itertools.chain.from_iterable(current_plugs))

                    if any(e in flatten_plugs for e in plugboard):
                        raise Exception(
                            "Invalid configuration: At least one with that configuration already exist!"
                        )
                    if any(e.lower() not in string.ascii_lowercase for e in plugboard):
                        raise Exception(
                            "One of the symbols cannot be inserted to the plugboard!"
                        )
                    if any(len(e) != 1 for e in plugboard):
                        raise Exception("One of the symbols is not a single character!")

                    # insert into database
                    await conn.execute(
                        """
                        UPDATE machines
                        SET plugboard_config = plugboard_config || $3::json
                        WHERE username = $1 AND id = $2
                        """,
                        username,
                        machine,
                        json.dumps(plugboard),
                    )

                    logging.info(
                        f"Saved plugboard [{plugboard}] to database for {username}.{machine}"
                    )

        except asyncpg.CheckViolationError:
            logging.error("There are already 10 Plugboards saved!")
            raise

    async def remove_plugboard(
        self, username: str, machine: int, key_1: str, key_2: str
    ) -> None:
        """removed a plugboard configuration if exists"""
        async with self.pool.acquire() as conn:
            async with conn.transaction():
                conn: asyncpg.Connection
                plugboard = [key_1.lower(), key_2.lower()]
                count = await self._get_plugboard_count(username, machine)

                boards = await self.get_plugboards(username, machine)
                boards = rustlib.drop_plugboard_pair(boards, plugboard)
                # boards = [json.dumps(b) for b in boards if set(b) != set(plugboard)]

                if count == len(boards):
                    raise Exception(
                        f"Trying to remove non-existent plugboard {plugboard} for {username}.{machine}"
                    )

                await conn.execute(
                    """
                    UPDATE machines
                    SET plugboard_config = $3
                    WHERE username = $1 AND id = $2
                    """,
                    username,
                    machine,
                    boards,
                )

    async def get_plugboards(self, username: str, machine: int) -> list:
        """returns all plugboard configurations for a machine"""
        async with self.pool.acquire() as conn:
            conn: asyncpg.Connection

            result = await conn.fetchval(
                """
                SELECT plugboard_config
                FROM machines
                WHERE username = $1 AND id = $2
                """,
                username,
                machine,
            )

            logging.info(f"Fetched plugboard for {username}.{machine}: {str(result)}")
            return [json.loads(pair) for pair in result or []]

    async def _get_plugboard_count(self, username: str, machine: int) -> int:
        """counts the number of currently set plugboards"""
        boards = await self.get_plugboards(username, machine)
        return len(boards)

    async def set_plugboard_enabled(
        self, username: str, machine: int, enabled: bool
    ) -> None:
        """toggles the plugboards state"""
        async with self.pool.acquire() as conn:
            conn: asyncpg.Connection

            await conn.execute(
                """
                UPDATE machines
                SET plugboard_enabled = $3
                WHERE username = $1 AND id = $2
                """,
                username,
                machine,
                enabled,
            )
            logging.info(f"Plugboard toggled for {username}.{machine}: {enabled}")

    async def is_plugboard_enabled(self, username: str, machine: int) -> bool:
        """returns weather the plugboard is enabled"""
        async with self.pool.acquire() as conn:
            conn: asyncpg.Connection

            result = await conn.fetchval(
                """
                Select plugboard_enabled
                FROM machines
                WHERE username = $1 AND id = $2
                """,
                username,
                machine,
            )
            logging.info(f"Plugboard enabled for {username}.{machine}: {result}")
            return bool(result)

    async def get_reflector(self, username: str, machine: int) -> dict:
        """returns reflector configurations for a machine"""
        async with self.pool.acquire() as conn:
            conn: asyncpg.Connection

            result = await conn.fetchval(
                """
                SELECT reflector
                FROM machines
                WHERE username = $1 AND id = $2
                """,
                username,
                machine,
            )

            logging.debug(f"Fetched reflector for {username}.{machine}: {str(result)}")
            return json.loads(result) if result else None

    async def get_reflector_id(self, username: str, machine_id: int) -> list:
        """returns refelector id for a machine"""
        async with self.pool.acquire() as conn:
            conn: asyncpg.Connection

            result = await conn.fetchval(
                """
                SELECT reflector_id
                FROM machines
                WHERE username = $1 AND id = $2
                """,
                username,
                machine_id,
            )

            logging.debug(
                f"Fetched reflector_id for {username}.{machine_id}: {str(result)}"
            )
            return result

    async def update_reflector_id(
        self, username: str, machine_id: int, reflector_id: int
    ) -> None:
        """returns return rotor configurations for a machine"""
        async with self.pool.acquire() as conn:
            conn: asyncpg.Connection

            await conn.execute(
                """
                UPDATE machines
                SET reflector_id = $3
                WHERE username = $1 AND id = $2
                """,
                username,
                machine_id,
                reflector_id,
            )

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    async def get_rotor_ids(self, username: str, machine: int) -> list[dict]:
        """returns all rotor ids for a machine type"""
        async with self.pool.acquire() as conn:
            conn: asyncpg.Connection

            result = await conn.fetch(
                """
                SELECT id
                FROM rotors
                WHERE username = $1 AND machine_type = $2 AND machine_id = 0 AND number = 0
                ORDER by id
                """,
                username,
                machine,
            )

            logging.debug(f"Fetched rotors for {username}.{machine}: {str(result)}")
            return [dict(pair) for pair in result or []]

    async def get_rotor_number(self, username: str, place: int, machine_id: int):
        """returns all rotor ids for a machine type"""
        async with self.pool.acquire() as conn:
            conn: asyncpg.Connection

            result = await conn.fetch(
                """
                SELECT number
                FROM rotors
                WHERE username = $1 AND place = $2 AND machine_id = $3
                """,
                username,
                place,
                machine_id,
            )

            logging.debug(
                f"Fetched rotornumber for {username}.{machine_id}: {str(result)}"
            )
            return dict(result[0]) if result else {"number": 1}

    async def get_rotor_templates(self, username: str, machine_id: int):
        """returns all rotor ids for a machine type"""
        async with self.pool.acquire() as conn:
            conn: asyncpg.Connection

            result = await conn.fetch(
                """
                SELECT *
                FROM rotors
                WHERE username = $1 AND machine_type = $2 AND machine_id = 0 AND number = 0
                """,
                username,
                machine_id,
            )

            logging.debug(f"Fetched rotors for {username}.{machine_id}: {str(result)}")
            return [dict(record) for record in result if record is not None]

    async def get_rotors(self, username: str, machine: int) -> list[dict]:
        """returns all rotors configurations for a machine"""
        async with self.pool.acquire() as conn:
            conn: asyncpg.Connection

            results = await conn.fetch(
                """
                SELECT *

                FROM rotors
                WHERE username = $1 AND machine_id = $2
                ORDER BY place
                """,
                username,
                machine,
            )

            logging.debug(f"Fetched rotors for {username}.{machine}: {str(results)}")
            return [dict(record) for record in results if record is not None]

    async def get_rotor(self, username: str, rotor: int) -> dict:
        """returns rotor configuration for a machine"""
        async with self.pool.acquire() as conn:
            conn: asyncpg.Connection

            result = await conn.fetchrow(
                """
                SELECT *
                FROM rotors
                WHERE id = $1
                """,
                rotor,
            )

            logging.debug(f"Fetched rotor for {rotor}: {str(result)}")
            return dict(result) if result else None

    async def get_rotor_by_place(
        self, username: str, machine_id: int, place: int
    ) -> dict:
        async with self.pool.acquire() as conn:
            conn: asyncpg.Connection

            result = await conn.fetchrow(
                """
                SELECT *
                FROM rotors
                WHERE username = $1 AND machine_id = $2 AND place = $3
                """,
                username,
                machine_id,
                place,
            )
            logging.debug(
                f"Fetched rotor for {username}.{machine_id}.{place}: {str(result)}"
            )
            return dict(result) if result else None

    async def get_rotor_by_number(
        self, username: str, number: int, machine_type: int, place: int
    ) -> dict:
        """returns rotor configuration for a machine"""
        async with self.pool.acquire() as conn:
            conn: asyncpg.Connection

            result = await conn.fetchrow(
                """
                SELECT *
                FROM rotors
                WHERE number = $1 AND username = $2 AND machine_type = $3 AND machine_id = 0 AND place = $4
                """,
                number,
                username,
                machine_type,
                place,
            )

            logging.debug(f"Fetched rotor for {number}: {str(result)}")
            return dict(result) if result else None

    async def update_rotors(self, username: str, rotors: list) -> None:
        for rotor in rotors:
            dict_rotor = vars(rotor)
            dict_rotor["username"] = username
            dict_rotor["rotor_position"] = Rotor.alphabet[dict_rotor["rotor_position"]]
            dict_rotor["letter_shift"] = rotor.get_str_notch()
            old_rotor = await self.get_rotor_by_number(
                username,
                dict_rotor["number"],
                dict_rotor["machine_id"],
                dict_rotor["place"],
            )
            await self.update_rotor(dict_rotor)
            dict_rotor["machine_type"] = dict_rotor["machine_id"]
            dict_rotor["machine_id"] = 0
            if old_rotor:
                dict_rotor["id"] = old_rotor["id"]
                await self.update_rotor(dict_rotor)
                continue
            await self.set_rotor(dict_rotor)

    async def update_rotor(self, data: dict) -> None:
        async with self.pool.acquire() as conn:
            async with conn.transaction():
                conn: asyncpg.Connection
                await conn.execute(
                    """
                    UPDATE rotors
                    SET place = $3, rotor_position = $4, letter_shift = $5, scramble_alphabet = $6, machine_id = $7, number = $8, is_rotate = $9, offset_value = $10
                    WHERE username = $1 AND id = $2
                    """,
                    data["username"],
                    data["id"],
                    data["place"],
                    data["rotor_position"].lower(),
                    data["letter_shift"].lower(),
                    data["scramble_alphabet"].lower(),
                    data["machine_id"],
                    data["number"],
                    data["is_rotate"],
                    data["offset_value"],
                )
        logging.debug(f"Updated rotor for {data['username']} with {data}")

    async def update_base_rotor(self, data: dict) -> None:
        async with self.pool.acquire() as conn:
            async with conn.transaction():
                conn: asyncpg.Connection
                await conn.execute(
                    """
                    UPDATE rotors
                    SET rotor_position = $2, offset_value = $3
                    WHERE id = $1
                    """,
                    data["id"],
                    data["rotor_position"],
                    data["offset_value"],
                )

    async def set_rotor(self, data: dict) -> int:
        async with self.pool.acquire() as conn:
            async with conn.transaction():
                await conn.execute(
                    """INSERT INTO rotors(username, scramble_alphabet, machine_type, machine_id, letter_shift, rotor_position, place, number, is_rotate, offset_value)
                    VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10);
                    """,
                    data["username"],
                    data["scramble_alphabet"].lower(),
                    data["machine_type"],
                    data["machine_id"],
                    data["letter_shift"].lower(),
                    data["rotor_position"].lower(),
                    data["place"],
                    data["number"],
                    data["is_rotate"],
                    data["offset_value"],
                )
                result = (
                    await conn.fetchval(
                        """
                    SELECT id
                    FROM rotors
                    WHERE username = $1 AND place = $2 AND machine_id = $3
                    """,
                        data["username"],
                        data["place"],
                        data["machine_id"],
                    ),
                )
            logging.debug(f"Created rotor for {data['username']}: {str(result)}")
            return result[0]

    async def switch_rotor(
        self, username: str, machine_id: int, template_id, place: int, number: int
    ) -> dict:
        id = 0
        async with self.pool.acquire() as conn:
            async with conn.transaction():
                id = await conn.fetchval(
                    """
                    SELECT id
                    FROM rotors
                    WHERE username = $1 AND machine_id = $2 AND place = $3
                    """,
                    username,
                    machine_id,
                    place,
                )

        template_rotor = await self.get_rotor(username, template_id)
        template_rotor["username"] = username
        template_rotor["place"] = place
        template_rotor["number"] = number

        if await self.get_rotor_by_number(username, number, machine_id, place) is None:
            await self.set_rotor(template_rotor)

        if id is None:
            template_rotor["machine_id"] = machine_id
            new_id = await self.set_rotor(template_rotor)
            return await self.get_rotor(username, new_id)

        before_rotor = await self.get_rotor(username, id)
        actual_rotor_id = before_rotor["id"]
        before_rotor["username"] = username
        before_rotor["id"] = (
            await self.get_rotor_by_number(
                username, before_rotor["number"], before_rotor["machine_id"], place
            )
        )["id"]
        before_rotor["machine_id"] = 0
        await self.update_rotor(before_rotor)

        after_rotor = await self.get_rotor_by_number(
            username, number, machine_id, place
        )
        after_rotor["username"] = username
        after_rotor["machine_id"] = machine_id
        after_rotor["id"] = actual_rotor_id
        await self.update_rotor(after_rotor)
        return await self.get_rotor(username, after_rotor["id"])

    async def get_machine(self, username: str, machine_id: int):
        plugboard = (
            await self.get_plugboards(username, machine_id)
            if await self.is_plugboard_enabled(username, machine_id)
            else []
        )
        reflector_id = await self.get_reflector_id(username, machine_id)
        reflector = (await self.get_reflector(username, machine_id))[reflector_id]

        rotors = []
        for rotor in await self.get_rotors(username, machine_id):
            rotors += [
                Rotor(
                    rotor["scramble_alphabet"],
                    rotor["rotor_position"],
                    rotor["letter_shift"],
                    rotor["id"],
                    rotor["machine_id"],
                    rotor["place"],
                    rotor["number"],
                    rotor["is_rotate"],
                    rotor["offset_value"],
                )
            ]
        return plugboard, reflector, rotors

    async def add_machine(
        self,
        username: str,
        name: str,
        plugboard: bool,
        number_rotors: int,
        rotors: list,
        reflectors: list,
    ) -> None:
        reflectors1 = await self.get_reflector(username, "1")
        reflectors2 = await self.get_reflector(username, "2")
        merged = {**reflectors1, **reflectors2}

        result_dict = {key: merged[key] for key in reflectors if key in merged}
        print(result_dict)
        new_machine_id = await self.create_machine(
            username, name, result_dict, plugboard, number_rotors
        )
        # rotors = await self.get_rotor_templates(username, machine_type)
        for rotor_id in rotors:
            rotor = await self.get_rotor(username, rotor_id)
            rotor["machine_id"] = 0
            rotor["machine_type"] = new_machine_id
            rotor["number"] = 0
            await self.set_rotor(rotor)

    async def delete_machine(self, username: str, machine_id: int) -> None:
        async with self.pool.acquire() as conn:
            async with conn.transaction():
                conn: asyncpg.Connection
                await conn.execute(
                    """
                    DELETE FROM rotors
                    WHERE machine_id = $1 AND username = $2
                    """,
                    machine_id,
                    username,
                )
                await conn.execute(
                    """
                    DELETE FROM rotors
                    WHERE username = $1 AND machine_type = $2 AND machine_id = 0
                    """,
                    username,
                    machine_id,
                )
                await conn.execute(
                    """
                    DELETE FROM machines
                    WHERE id = $1
                    """,
                    machine_id,
                )

    async def revert_machine(self, username, machine_id) -> None:
        rotors = await self.get_rotors(username, machine_id)
        revert_rotor = await self.get_rotor_by_number(username, 0, machine_id, 0)
        revert_rotor["number"] = 1
        for rotor in rotors:
            revert_rotor["place"] = rotor["place"]
            revert_rotor["id"] = rotor["id"]
            await self.update_rotor(revert_rotor)  # Needs some more doing

        async with self.pool.acquire() as conn:
            async with conn.transaction():
                conn: asyncpg.Connection

                await conn.execute(
                    """
                    UPDATE machines
                    SET character_pointer = -1, character_history = ARRAY[]::JSON[], plugboard_enabled = FALSE, plugboard_config = ARRAY[]::JSON[], reflector_id = $3
                    WHERE id = $1 AND username = $2
                    """,
                    machine_id,
                    username,
                    list((await self.get_reflector(username, machine_id)).keys())[0],
                )

                await conn.execute(
                    """
                    DELETE FROM rotors
                    WHERE username = $1 AND machine_type = $2 AND machine_id = 0 AND number <> 0
                    """,
                    username,
                    machine_id,
                )


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


def get_database() -> Database:
    if Database.instance is None:
        logging.info("Creating new Database instance...")
        Database.instance = Database()

    return Database.instance
