import logging

from fastapi import FastAPI
from server.lib import *

# init fastapi and db
app = FastAPI()

# logging
configure_logger()
logging.info('FastAPI is starting up...')

db = get_database()
db.fastapi_init(app)

app.include_router(router)