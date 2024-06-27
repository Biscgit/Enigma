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
                "offset_value": rotor.offset_value,
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
    try:
        rotor = await db_conn.get_rotor(username, rotor)
        if rotor is None:
            raise HTTPException(status_code=404, detail="Rotor not found")
    except Exception as e:
        print("Error: ", e)
        raise HTTPException(status_code=404, detail="Can't get Rotor")

    return rotor


@router.get("/get-rotors")
async def get_rotors(
    machine_id: int,
    username: str = Depends(check_auth),
    db_conn: "Database" = Depends(get_database),
) -> Dict[str, Dict[str, str | int | None]]:
    try:
        rotors = await db_conn.get_rotors(username, machine_id)
        if rotors == []:
            raise HTTPException(status_code=404, detail="Rotors not found")
        result = {}
        for i, rotor in enumerate(rotors):
            result[f"Rotor {i}"] = rotor
    except Exception as e:
        print("Error: ", e)
        raise HTTPException(status_code=404, detail="Can't get Rotors")
    return result


@router.get("/get-rotor-ids")
async def get_rotor_ids(
    machine_id: int,
    username: str = Depends(check_auth),
    db_conn: "Database" = Depends(get_database),
) -> list[Dict[str, int]]:
    try:
        rotor_ids = await db_conn.get_rotor_ids(username, machine_id)
    except Exception as e:
        print("Error: ", e)
        raise HTTPException(status_code=404, detail="Can't get Rotor ids")

    return rotor_ids


@router.get("/get-rotor-by-place")
async def get_rotor_by_place(
    machine_id: int,
    place: int,
    username: str = Depends(check_auth),
    db_conn: "Database" = Depends(get_database),
) -> Dict[str, str | int | None] | None:
    try:
        rotor = await db_conn.get_rotor_by_place(username, machine_id, place)
    except Exception as e:
        print("Error: ", e)
        raise HTTPException(status_code=404, detail="Can't get Rotor by place")

    return rotor


@router.get("/get-rotor-number")
async def get_rotor_number(
    machine_id: int,
    place: int,
    username: str = Depends(check_auth),
    db_conn: "Database" = Depends(get_database),
) -> Dict[str, int]:
    try:
        rotor_number = await db_conn.get_rotor_number(username, place, machine_id)
    except Exception as e:
        print("Error: ", e)
        raise HTTPException(status_code=404, detail="Can't get Rotor number")
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
            rotor.template_id,
            rotor.place,
            rotor.number,
        )
    except Exception as e:
        print("Error: ", e)
        raise HTTPException(status_code=404, detail="Can't switch Rotor")
    return rotor


@router.post("/add-machine")
async def add_machine(
    name: str,
    machine_type: int,
    plugboard: bool,
    number_rotors: int,
    username: str = Depends(check_auth),
    db_conn: "Database" = Depends(get_database),
) -> None:
    try:
        await db_conn.add_machine(
            username, name, machine_type, plugboard, number_rotors
        )
    except Exception as e:
        print("Error: ", e)
        raise HTTPException(status_code=400, detail="Can't add Machine")
    return {"Status": "OK"}


@router.delete("/delete-machine")
async def delete_machine(
    machine_id: int,
    username: str = Depends(check_auth),
    db_conn: "Database" = Depends(get_database),
) -> None:
    try:
        await db_conn.delete_machine(username, machine_id)
    except Exception as e:
        print("Error: ", e)
        raise HTTPException(status_code=404, detail="Can't delete Machine")
    return {"Status": "OK"}


@router.get("/get-machines")
async def get_machines(
    username: str = Depends(check_auth),
    db_conn: "Database" = Depends(get_database),
) -> list:
    try:
        machines = await db_conn.get_machines(username)
        del machines[0]
    except Exception as e:
        print("Error: ", e)
        raise HTTPException(status_code=404, detail="Can't get Machines")
    return machines


@router.post("/revert-machine")
async def revert_machine(
    machine_id: int,
    username: str = Depends(check_auth),
    db_conn: "Database" = Depends(get_database),
) -> Dict[str, str]:
    try:
        await db_conn.revert_machine(username, machine_id)
    except Exception as e:
        print("Error: ", e)
        raise HTTPException(status_code=404, detail="Can't revert Machine")
    return {"Status": "OK"}


@router.get("/get-reflector-ids")
async def get_reflector_ids(
    machine_id: int,
    username: str = Depends(check_auth),
    db_conn: "Database" = Depends(get_database),
) -> list:
    try:
        ids = list((await db_conn.get_reflector(username, machine_id)).keys())
    except Exception as e:
        print("Error: ", e)
        raise HTTPException(status_code=404, detail="Can't get reflector ids")
    return ids


@router.get("/get-reflector-id")
async def get_reflector_id(
    machine_id: int,
    username: str = Depends(check_auth),
    db_conn: "Database" = Depends(get_database),
) -> str:
    try:
        ids = await db_conn.get_reflector_id(username, machine_id)
    except Exception as e:
        print("Error: ", e)
        raise HTTPException(status_code=404, detail="Can't get reflector id")
    return ids


@router.post("/update-reflector")
async def update_reflector(
    reflector_id: str,
    machine_id: int,
    username: str = Depends(check_auth),
    db_conn: "Database" = Depends(get_database),
) -> Dict[str, str]:
    try:
        await db_conn.update_reflector_id(username, machine_id, reflector_id)
    except Exception as e:
        print("Error: ", e)
        raise HTTPException(status_code=404, detail="Can't update reflector Id")
    return {"Status": "OK"}
