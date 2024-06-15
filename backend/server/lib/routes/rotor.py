from fastapi import APIRouter, Depends, HTTPException
from .authentication import check_auth
from server.lib.database import get_database, Database
from typing import Dict
from server.lib.models import Rotor, MinRotor

router = APIRouter()


@router.post("/update-rotor")
async def update_rotor(
    rotor: Rotor,
    username: str = Depends(check_auth),
    db_conn: "Database" = Depends(get_database),
) -> Dict[str, str]:
    try:
        await db_conn.update_rotor(
            {
                "username": username,
                "id": rotor.id,
                "rotor_position": rotor.rotor_position,
                "letter_shift": rotor.letter_shift,
                "scramble_alphabet": rotor.scramble_alphabet,
                "machine_id": rotor.machine_id,
                "place": rotor.place,
                "number": rotor.number,
                "is_rotate": rotor.is_rotate,
            }
        )
    except Exception as e:
        print("Error: ", e)
        raise HTTPException(status_code=404, detail="Can't update Rotor")
    return {"Status": "OK"}


@router.get("/get-rotor")
async def get_rotor(
    rotor: int,
    username: str = Depends(check_auth),
    db_conn: "Database" = Depends(get_database),
) -> Dict[str, str | int | None]:
    rotor = await db_conn.get_rotor(username, rotor)
    if rotor is None:
        raise HTTPException(status_code=404, detail="Rotor not found")
    return rotor


@router.get("/get-rotors")
async def get_rotors(
    machine_id: int,
    username: str = Depends(check_auth),
    db_conn: "Database" = Depends(get_database),
) -> Dict[str, Dict[str, str | int | None]]:
    rotors = await db_conn.get_rotors(username, machine_id)
    if rotors == []:
        raise HTTPException(status_code=404, detail="Rotors not found")
    result = {}
    for i, rotor in enumerate(rotors):
        result[f"Rotor {i}"] = rotor
    return result


@router.get("/get-rotor-ids")
async def get_rotor_ids(
    machine_id: int,
    username: str = Depends(check_auth),
    db_conn: "Database" = Depends(get_database),
) -> list[Dict[str, int]]:
    rotor_ids = await db_conn.get_rotor_ids(username, machine_id)
    return rotor_ids


@router.get("/get-rotor-number")
async def get_rotor_number(
    machine_id: int,
    place: int,
    username: str = Depends(check_auth),
    db_conn: "Database" = Depends(get_database),
) -> Dict[str, int]:
    rotor_number = await db_conn.get_rotor_number(username, place, machine_id)
    return rotor_number


@router.post("/switch-rotor")
async def add_rotor(
    rotor: MinRotor,
    username: str = Depends(check_auth),
    db_conn: "Database" = Depends(get_database),
) -> Dict[str, int | str]:
    try:
        rotor = await db_conn.switch_rotor(
            username,
            rotor.machine_id,
            rotor.id,
            rotor.template_id,
            rotor.place,
            rotor.number,
        )
        print(rotor)
    except Exception as e:
        print("Error: ", e)
        raise HTTPException(status_code=404, detail="Can't switch Rotor")
    return rotor
