__all__ = ["Database"]

import asyncio
import logging
from os import environ

import asyncpg
import fastapi


class Database:
    """Database interface"""
    max_chars = 140

    def __init__(self, app: fastapi.FastAPI):
        self.pool: asyncpg.Pool | None = None

        # ensure clean startup and shutdown
        @app.on_event("startup")
        async def connect_db():
            await self.connect()

        @app.on_event("shutdown")
        async def connect_db():
            await self.disconnect()

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

                await self.initialize_db()
                return

        logging.critical("Failed to connect to database after 60 seconds")
        exit(1)

    async def initialize_db(self):
        logging.info("Initializing database...")

        with open("./server/other/initialize.sql") as file:
            content = file.read()

            async with self.pool.acquire() as conn:
                async with conn.transaction():
                    for qry in content.split(";"):
                        if qry.strip():
                            await conn.execute(qry)

        logging.info("Successfully initialized database")

    async def disconnect(self) -> None:
        await self.pool.close()
        logging.info("Successfully disconnected to database")

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
