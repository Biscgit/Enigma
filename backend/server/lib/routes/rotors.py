from fastapi import APIRouter, Depends, HTTPException
from .authentication import check_auth
from server.lib.database import get_database, Database

router = APIRouter()


@router.post("/set-rotor")
async def set_rotor(
    rotor: int,
    start: chr,
    notch: chr,
    username: str = Depends(check_auth),
    db_conn: "Database" = Depends(get_database),
):
    pass


@router.get("/get-rotor")
async def get_rotor(
    rotor: int,
    username: str = Depends(check_auth),
    db_conn: "Database" = Depends(get_database),
) -> dict[str, str]:
    rotor = await db_conn.get_rotor(username, rotor)
    return {"rotor"}
