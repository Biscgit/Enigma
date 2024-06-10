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

            except ConnectionRefusedError:
                logging.info('Retrying to connect...')
                await asyncio.sleep(5)

            else:
                self.pool = conn

                async with self.pool.acquire() as c:
                    async with c.transaction():
                        version = await conn.fetchval("SELECT version()")

                logging.info(f"Successfully connected to database {version}")

                await self._initialize_db()
                await self._load_users()
                return

        logging.critical("Failed to connect to database after 30 seconds")
        exit(1)

    async def _initialize_db(self, create_machines: bool = True) -> None:
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

                    # create default machines
                    if create_machines:
                        for index in range(3):
                            for i, u in enumerate(["user1", "user2"]):
                                try:
                                    await self.create_machine(u, i + 1, index + 1)
                                except Exception:
                                    continue

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
                    content
                )

        logging.info("Successfully loaded users from file")

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
                    form.username, form.password
                )

                return result

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    async def save_keyboard_pair(self, username: str, machine: int, clear: str, encrypted: str) -> None:
        """saves a key pair into the database history"""
        async with self.pool.acquire() as conn:
            async with conn.transaction():
                conn: asyncpg.Connection

                if any(e.lower() not in string.ascii_lowercase for e in [clear, encrypted]):
                    raise Exception("One of the symbols cannot be inserted as history!")
                if any(len(e) != 1 for e in [clear, encrypted]):
                    raise Exception("One of the symbols is not a single character!")

                pointer = await self._get_history_pointer_position(conn, username, machine)
                pointer = (pointer + 1) % Database.char_max

                # update the pointer and add character-pair in O(1) time
                await conn.execute(
                    f"""
                    UPDATE machines
                    SET character_history[{pointer}] = $4::json,
                        character_pointer = $3
                    WHERE username = $1 AND id = $2
                    """,
                    username, machine, pointer, json.dumps([clear, encrypted])
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
                    username, machine
                )

                logging.info(f"Fetched key-pairs for {username}.{machine}: {str(result)[:80]}")
                return [json.loads(pair) for pair in result or []]

    @staticmethod
    async def _get_history_pointer_position(conn: asyncpg.Connection, username: str, machine: int) -> int:
        """Returns the point position of the current history. The value is between 0-139 or -1 if not set"""
        try:
            return int(await conn.fetchval(
                """
                SELECT character_pointer
                FROM machines
                WHERE username = $1 AND id = $2
                """,
                username, machine
            ))

        except TypeError:
            logging.error(f"Machine {username}.{machine} does not exist!")
            raise

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    async def save_plugboard(self, username: str, machine: int, key_1: str, key_2: str) -> None:
        """saves a plugboard configuration to a machine"""
        try:
            async with self.pool.acquire() as conn:
                async with conn.transaction():
                    conn: asyncpg.Connection
                    plugboard = [key_1, key_2]

                    # execute a check before inserting
                    current_plugs = await self.get_plugboards(username, machine)
                    flatten_plugs = set(itertools.chain.from_iterable(current_plugs))

                    if any(e in flatten_plugs for e in plugboard):
                        raise Exception("Invalid configuration: At least one with that configuration already exist!")
                    if any(e.lower() not in string.ascii_lowercase for e in plugboard):
                        raise Exception("One of the symbols cannot be inserted to the plugboard!")
                    if any(len(e) != 1 for e in plugboard):
                        raise Exception("One of the symbols is not a single character!")

                    # insert into database
                    await conn.execute(
                        """
                        UPDATE machines
                        SET plugboard_config = plugboard_config || $3::json
                        WHERE username = $1 AND id = $2
                        """,
                        username, machine, json.dumps(plugboard)
                    )

                    logging.info(f"Saved plugboard [{plugboard}] to database for {username}.{machine}")

        except asyncpg.CheckViolationError:
            logging.error("There are already 10 Plugboards saved!")
            raise

    async def remove_plugboard(self, username: str, machine: int, key_1: str, key_2: str) -> None:
        """removed a plugboard configuration if exists"""
        async with self.pool.acquire() as conn:
            async with conn.transaction():
                conn: asyncpg.Connection
                plugboard = [key_1, key_2]
                count = await self._get_plugboard_count(username, machine)

                boards = await self.get_plugboards(username, machine)
                boards = rustlib.drop_plugboard_pair(boards, plugboard)
                # boards = [json.dumps(b) for b in boards if set(b) != set(plugboard)]

                if count == len(boards):
                    raise Exception(f"Trying to remove non-existent plugboard {plugboard} for {username}.{machine}")

                await conn.execute(
                    """
                    UPDATE machines
                    SET plugboard_config = $3
                    WHERE username = $1 AND id = $2
                    """,
                    username, machine, boards
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
                username, machine,
            )

            logging.info(f"Fetched plugboard for {username}.{machine}: {str(result)}")
            return [json.loads(pair) for pair in result or []]

    async def _get_plugboard_count(self, username: str, machine: int) -> int:
        """counts the number of currently set plugboards"""
        boards = await self.get_plugboards(username, machine)
        return len(boards)

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    async def create_machine(self, username: str, machine_id: int, machine_type: int) -> None:
        """creates a new machine for a user if it does not exist"""

        async with self.pool.acquire() as conn:
            async with conn.transaction():
                conn: asyncpg.Connection

                count = await conn.fetchval(
                    """
                    SELECT COUNT(*)
                    FROM machines
                    WHERE username = $1 AND id = $2
                    """,
                    username, machine_id
                )
                if count > 0:
                    logging.error(f"Machine {username}.{machine_id} already exists!")
                    raise Exception(f"Machine {username}.{machine_id} already exists!")

                await conn.execute(
                    """
                    INSERT INTO machines (
                        id, username, machine_type, 
                        character_pointer, character_history, 
                        plugboard_enabled, plugboard_config)
                    VALUES (
                        $1, 
                        $2, 
                        $3,
                        -1,
                        ARRAY[]::JSON[],
                        FALSE,
                        ARRAY[]::JSON[]
                    )
                    """,
                    machine_id, username, machine_type
                )

                logging.info(f"Created machine {username}.{machine_id} of type {machine_type}")


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


def get_database() -> Database:
    if Database.instance is None:
        logging.info("Creating new Database instance...")
        Database.instance = Database()

    return Database.instance
