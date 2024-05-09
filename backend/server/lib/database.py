__all__ = ["get_database", "Database"]

import asyncio
import logging
from os import environ

import asyncpg
import fastapi

from .models import LoginForm


class Database:
    """Database interface"""
    max_chars = 140
    instance: "Database" = None

    def __init__(self):
        self.pool: asyncpg.Pool | None = None

        self.__is_inited: bool = False

    def fastapi_init(self, app: fastapi.FastAPI):
        """Ensure clean startup and shutdown. Needs to be called before start"""

        if self.__is_inited:
            raise Exception("Database has already been inited with fastapi")

        @app.on_event("startup")
        async def connect_db():
            await self.connect()

        @app.on_event("shutdown")
        async def disconnect_db():
            await self.disconnect()

        self.__is_inited = True

    async def connect(self) -> None:
        logging.info("Connecting to database...")

        for _ in range(12):
            try:
                conn: asyncpg.Pool = await asyncpg.create_pool(
                    user=environ.get("DB_USER"),
                    password=environ.get("DB_PASSWORD"),
                    database=environ.get("DB_NAME"),
                    host=environ.get("IP_POSTGRES"),
                )

            except ConnectionRefusedError:
                await asyncio.sleep(5)

            else:
                self.pool = conn
                logging.info("Successfully connected to database")

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
                        (data->>'password')::TEXT
                    FROM json_array_elements($1::json) as data
                    ON CONFLICT (username) DO UPDATE
                    SET password = EXCLUDED.password;
                    """,
                    content
                )

        logging.info("Successfully loaded users from file")

    async def disconnect(self) -> None:
        await self.pool.close()
        logging.info("Successfully disconnected to database")

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    async def check_login(self, form: LoginForm) -> bool:
        """returns a bool for weather the credentials are valid"""
        async with self.pool.acquire() as conn:
            async with conn.transaction():
                result: int = await conn.fetchval(
                    """
                    SELECT COUNT(*) 
                    FROM  users
                    WHERE username = $1 AND password = $2;
                    """,
                    form.username, form.password
                )

                return bool(result)


def get_database() -> Database:
    if Database.instance is None:
        logging.info("Creating new Database instance...")
        Database.instance = Database()

    return Database.instance
