from fastapi import APIRouter, Depends
from server.lib.database import get_database, Database

from .authentication import check_auth

router = APIRouter()

def encrypt(machine_id: int, char: chr):
    # rotors, plugboard, return_rotor = get_machine(machine_id)
    notch = True
#    char = plugboard.switch_letter(char)

    for i in rotors:
        notch, char = i.rotate_offset_scramble(char, notch, False)

 #   value = return_rotor.switch_letter(value)

    for i in rotors:
        notch, char = i.rotate_offset_scramble(char, notch, True)

    return char # plugboard.switch_letter(char)

@router.get("/key_press")
async def encrypt_key(
        key: str, machine: int,
        username: str = Depends(check_auth),
        db_conn: "Database" = Depends(get_database)
) -> dict:
    """Endpoint for logging key presses. Takes token, key and machine id. Returns encrypted key"""

    # ToDo: implement encryption here and store it to `encrypted_key`
    # ToDo: implement check if machine exists
    # ToDo: add unit + integration tests when completed
    encrypted_key: str = "o"

    # save to history and return key
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
