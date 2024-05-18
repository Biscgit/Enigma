import asyncpg
from testcontainers.postgres import PostgresContainer


async def create_db_with_users(pg: PostgresContainer, users, monkeypatch) -> asyncpg.Connection:
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
