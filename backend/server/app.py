import logging

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from server.lib import *

# init fastapi and db
configure_logger()

db = get_database()
app = FastAPI(lifespan=db.fastapi_lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allow_headers=["*"],
)

# logging
logging.info('FastAPI is starting up...')
app.include_router(router)
