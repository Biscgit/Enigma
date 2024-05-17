__all__ = ["get_database", "Database"]

import asyncio
import contextlib
import json
import logging
from os import environ

import asyncpg
import fastapi

from .models import LoginForm
from rustlib import list_length


class Database:
    """Database interface"""
    max_chars = 140
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
        logging.info(f"Length 3 = {list_length([1, 2, 3])}")

        if self.pool is not None:
            raise Exception("Database connection is already established")

        for _ in range(12):
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

        logging.critical("Failed to connect to database after 60 seconds")
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
                    content
                )

        logging.info("Successfully loaded users from file")

    async def disconnect(self) -> None:
        if self.pool is None:
            raise Exception("There is no connection to close!")

        await self.pool.close()
        self.pool = None

        logging.info("Successfully disconnected to database")

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

                pointer = await self._get_history_pointer_position(conn, username, machine)
                pointer = (pointer + 1) % Database.max_chars

                # update the pointer and add character-pair
                await conn.execute(
                    f"""
                    UPDATE machines
                    SET character_history[{pointer}] = $4,
                        character_pointer = $3
                    WHERE username = $1 AND id = $2
                    """,
                    username, machine, pointer, json.dumps([clear, encrypted])
                )

                logging.info(f"Saved key-pair to database with index {pointer}")

    async def get_key_pairs(self, username: str, machine: int) -> list:
        """returns key-pairs in last inserted first order"""
        async with self.pool.acquire() as conn:
            async with conn.transaction():
                conn: asyncpg.Connection
                result = await conn.fetchval(
                    f"""
                    WITH indexed_history AS (
                        SELECT 
                            elem,
                            (character_pointer - index + 1 + 140) % 140 AS shifted_index
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
        return int(await conn.fetchval(
            """
            SELECT character_pointer
            FROM machines
            WHERE username = $1 AND id = $2
            """,
            username, machine
        ))

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


def get_database() -> Database:
    if Database.instance is None:
        logging.info("Creating new Database instance...")
        Database.instance = Database()

    return Database.instance
