__all__ = ["router"]

from fastapi import APIRouter#, Depends, HTTPException
#from server.lib.models import
from server.lib.encrypt import *

router = APIRouter()

encrypter = Encrypter()

@router.post("/encrypt")
async def encrypt(char: chr) -> chr:
    return encrypter.encrypt(char)
    

@router.post("/new-machine")
async def new_machine() -> None:
    pass

@asnyc.put("/load-machine")
async def load_machine(ID: int) -> None:
    pass
