from fastapi import APIRouter, Depends
from .authentication import check_auth
from server.lib.database import get_database, Database
from typing import Dict

router = APIRouter()


@router.post("/update-rotor")
async def update_rotor(
    rotor: int,
    start: str,
    notch: str,
    scramble_alphabet: str,
    username: str = Depends(check_auth),
    db_conn: "Database" = Depends(get_database),
) -> Dict[str, str]:
    await db_conn.update_rotor(username, rotor, start, notch, scramble_alphabet)
    return {"Status": "OK"}


@router.get("/get-rotor")
async def get_rotor(
    rotor: int,
    username: str = Depends(check_auth),
    db_conn: "Database" = Depends(get_database),
) -> Dict[str, str]:
    rotor = await db_conn.get_rotor(username, rotor)
    print(rotor)
    return {"rotor": "s"}
