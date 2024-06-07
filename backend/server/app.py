import this  # noqa
import logging

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from server.lib.database import get_database
from server.lib.logger import configure_logger
from server.lib.routes import authentication, key_input, rotor

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

# load routes
logging.info("Loading routes...")
app.include_router(authentication.router)
app.include_router(key_input.router)
app.include_router(rotor.router)
