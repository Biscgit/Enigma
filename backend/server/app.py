import logging

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from server.lib import *

# init fastapi and db
app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allow_headers=["*"],
)

# logging
configure_logger()
logging.info('FastAPI is starting up...')

db = get_database()
db.fastapi_init(app)

app.include_router(router)
