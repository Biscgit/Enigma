import logging

from fastapi import FastAPI
from server.lib import *

logging.basicConfig(level=logging.INFO)

app = FastAPI()
db = Database()


@app.on_event("startup")
async def connect_db():
    await db.connect()


@app.on_event("shutdown")
async def connect_db():
    await db.disconnect()
