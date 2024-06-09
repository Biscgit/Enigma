from fastapi import APIRouter, Depends, HTTPException
from server.lib.database import get_database, Database
from .authentication import check_auth

router = APIRouter()


@router.get("/key_press")
async def encrypt_key(
        key: str, machine: int,
        username: str = Depends(check_auth),
        db_conn: "Database" = Depends(get_database)
) -> dict:
    """Endpoint for logging key presses. Takes token, key and machine id. Returns the switched key"""

    # Attempt to get plugboard configurations to check if machine exists
    try:
        plugs = await db_conn.get_plugboards(username, machine)
    except Exception:
        raise HTTPException(status_code=404, detail="Machine not found")

    # Get the switched letter from the plugboard
    switched_letter = get_switched_letter(plugs, key)

    # Save to history and return the switched key
    await db_conn.save_keyboard_pair(username, machine, key, switched_letter)
    return {"key": switched_letter}


def get_switched_letter(plugs: list, key: str) -> str:
    # Find the plugboard connection for the key
    for plug in plugs:
        if key in plug:
            return plug[1] if key == plug[0] else plug[0]

    # If the key is not found in the plugboard, return the key itself
    return key


@router.get("/load_key_history")
async def load_key_history(
        machine: int,
        username: str = Depends(check_auth),
        db_conn: "Database" = Depends(get_database)
) -> list[list[str]]:
    """Endpoint for loading key history. Takes token and machine id. Returns history of keys pressed"""
    return await db_conn.get_key_pairs(username, machine)
