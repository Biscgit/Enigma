import logging

from fastapi import FastAPI
from server.lib import *

logging.basicConfig(level=logging.INFO)

app = FastAPI()
db = Database(app)
