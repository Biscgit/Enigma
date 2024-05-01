import logging

from fastapi import FastAPI
from server.lib import *

logging.basicConfig(level=logging.INFO)

# init fastapi and db
app = FastAPI()
db = get_database()
db.fastapi_init(app)

# add routes
