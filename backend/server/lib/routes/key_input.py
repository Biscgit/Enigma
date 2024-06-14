from fastapi import APIRouter, Depends
from server.lib.database import get_database, Database
from server.lib.plugboard import reflect_letter, to_dict
from .authentication import check_auth
import json

router = APIRouter()

machines = {}


async def encrypt(username: str, machine_id: int, db_conn: Database, char: chr) -> chr:
    global machines
    plugboard, reflector, rotors = machines.get(
        f"{username}:{machine_id}", await db_conn.get_machine(username, machine_id)
    )

    notch = True
    char = reflect_letter(char, to_dict(plugboard))

    for i in range(len(rotors)):
        notch, char = rotors[i].rotate_offset_scramble(char, notch, False)

    char = reflect_letter(char, json.loads(reflector))
    notch = False

    for i in range(len(rotors) - 1, -1, -1):
        notch, char = rotors[i].rotate_offset_scramble(char, notch, True)

    # machines[f"{username}:{machine_id}"] = (plugboard, reflector, rotors)
    await db_conn.update_rotors(username, rotors)
    return reflect_letter(char, to_dict(plugboard))


@router.get("/key_press")
async def encrypt_key(
    key: str,
    machine: int,
    username: str = Depends(check_auth),
    db_conn: "Database" = Depends(get_database),
) -> dict:
    """Endpoint for logging key presses. Takes token, key and machine id. Returns the switched key"""

    # ToDo: implement encryption here and store it to `encrypted_key`
    # ToDo: implement check if machine exists
    # ToDo: add unit + integration tests when completed
    encrypted_key: str = await encrypt(username, machine, db_conn, key)

    # Save to history and return the switched key
    await db_conn.save_keyboard_pair(username, machine, key, encrypted_key)
    return {"key": encrypted_key}


@router.get("/load_key_history")
async def load_key_history(
    machine: int,
    username: str = Depends(check_auth),
    db_conn: "Database" = Depends(get_database),
) -> list[list[str]]:
    """Endpoint for loading key history. Takes token and machine id. Returns history of keys pressed"""
    return await db_conn.get_key_pairs(username, machine)


@router.get("/ping")
async def ping():
    return "OK"
