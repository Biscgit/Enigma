from fastapi import APIRouter, Depends
from server.lib.database import get_database, Database
from server.lib.plugboard import switch_letter
from .authentication import check_auth

router = APIRouter()


@router.get("/key_press")
async def encrypt_key(
        key: str, machine: int,
        username: str = Depends(check_auth),
        db_conn: "Database" = Depends(get_database)
) -> dict:
    """Endpoint for logging key presses. Takes token, key and machine id. Returns the switched key"""

    # ToDo: implement encryption here and store it to `encrypted_key`
    # ToDo: implement check if machine exists
    # ToDo: add unit + integration tests when completed
    encrypted_key: str = "o"

    # apply plugboard
    encrypted_key = await switch_letter(username, machine, encrypted_key, db_conn)

    # Save to history and return the switched key
    await db_conn.save_keyboard_pair(username, machine, key, encrypted_key)
    return {"key": encrypted_key}


@router.get("/load_key_history")
async def load_key_history(
        machine: int,
        username: str = Depends(check_auth),
        db_conn: "Database" = Depends(get_database)
) -> list[list[str]]:
    """Endpoint for loading key history. Takes token and machine id. Returns history of keys pressed"""
    return await db_conn.get_key_pairs(username, machine)


@router.get("/ping")
async def ping():
    return "OK"
