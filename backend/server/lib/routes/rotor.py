from fastapi import APIRouter, Depends
from .authentication import check_auth
from server.lib.database import get_database, Database
from typing import Dict

router = APIRouter()


@router.post("/set-rotor")
async def set_rotor(
    rotor: int,
    start: str,
    notch: str,
    scramble_alphabet: str,
    username: str = Depends(check_auth),
    db_conn: "Database" = Depends(get_database),
) -> Dict[str, str]:
    #  message = await db_conn.set_rotor(username, rotor, start, notch, scramble_alphabet)
    return {"s": "s"}  # message


@router.get("/get-rotor")
async def get_rotor(
    rotor: int,
    username: str = Depends(check_auth),
    db_conn: "Database" = Depends(get_database),
) -> Dict[str, str]:
    rotor = await db_conn.get_rotor(username, rotor)
    print(rotor)
    return {"rotor": "s"}
