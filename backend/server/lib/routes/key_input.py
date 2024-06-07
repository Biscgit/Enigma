from fastapi import APIRouter, Depends
from server.lib.database import get_database, Database

from .authentication import check_auth

router = APIRouter()

machines = {}

async def encrypt(username: str, machine_id: int, db_conn: Database,  char: chr) -> chr:
    global machines
    rotors, plugboard, return_rotor = machines.get(f"{username}:{machine_id}", await db_conn.get_machine(username, machine_id))

    notch = True
#    char = plugboard.switch_letter(char)

    for rotor in rotors:
        notch, char = rotor.rotate_offset_scramble(char, notch, False)

 #   value = return_rotor.switch_letter(value)

    for rotor in rotors:
        notch, char = rotor.rotate_offset_scramble(char, notch, True)

    machines[f"{username}:{machine_id}"] = (rotors, plugboard, return_rotor)
    await db_conn.update_rotors(rotors)
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
    encrypted_key: str = await encrypt(username, machine, db_conn, key)

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
