from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, field_validator
from typing import List
from server.lib.database import get_database, Database
from .authentication import check_auth

import logging

router = APIRouter(prefix="/plugboard")

MAX_PLUGS = 10


# Pydantic model for plug configurations
class PlugConfig(BaseModel):
    plug_a: str
    plug_b: str

    @field_validator('plug_a', 'plug_b')
    def validate_letters(cls, v):
        if len(v) != 1 or not v.isalpha():
            raise ValueError("Letters must be a single alphabetic character")
        return v.lower()


# Response model
class PlugboardResponse(BaseModel):
    plugboard: List[List[str]]


# Additional Response model for reset operation
class ResetPlugboardResponse(BaseModel):
    message: str


@router.post("/save", response_model=PlugboardResponse)
async def configure_plugboard(
        plug_a: str,
        plug_b: str,
        machine: int,
        username: str = Depends(check_auth),
        db: Database = Depends(get_database)
):
    plugs = await db.get_plugboards(username, machine)
    if len(plugs) >= MAX_PLUGS:
        raise HTTPException(status_code=400, detail="Too many plugboard configurations")

    plug_a = plug_a.lower()
    plug_b = plug_b.lower()

    for existing_plug in plugs:
        if plug_a in existing_plug or plug_b in existing_plug:
            raise HTTPException(status_code=400, detail="Duplicate letter detected")

    await db.save_plugboard(username, machine, plug_a, plug_b)
    return {"plugboard": plugs}


@router.get("/load", response_model=PlugboardResponse)
async def get_configuration(
        machine: int,
        username: str = Depends(check_auth),
        db: Database = Depends(get_database)
):
    try:
        plugs = await db.get_plugboards(username, machine)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

    return {"plugboard": plugs}


@router.put("/edit", response_model=PlugboardResponse)
async def edit_plugboard(
        machine: int,
        letter: str,
        new_plug: PlugConfig,
        username: str = Depends(check_auth),
        db: Database = Depends(get_database)
):
    letter_upper = letter.upper()
    plugs = await db.get_plugboards(username, machine)

    if letter_upper not in [p[0] for p in plugs]:
        raise HTTPException(status_code=404, detail="Letter does not exist in the plugboard")

    old_plug = next(p for p in plugs if p[0] == letter_upper)

    new_plug_a_upper = new_plug.plug_a.upper()
    new_plug_b_upper = new_plug.plug_b.upper()

    for existing_plug in plugs:
        if new_plug_a_upper in existing_plug or new_plug_b_upper in existing_plug:
            raise HTTPException(status_code=400, detail="Duplicate letter detected")

    await db.remove_plugboard(username, machine, old_plug[0], old_plug[1])
    await db.save_plugboard(username, machine, new_plug_a_upper, new_plug_b_upper)
    return {"plugboard": plugs}


@router.delete("/remove", response_model=ResetPlugboardResponse)  # Change response model here
async def delete_plugboard_pair(
        machine: int,
        plug_a: str,
        plug_b: str,
        username: str = Depends(check_auth),
        db: Database = Depends(get_database)
):
    try:
        await db.remove_plugboard(username, machine, plug_a, plug_b)
    except Exception as e:
        logging.error(f"Error removing plugboard pair: {type(e)} -> {e}")
        raise HTTPException(status_code=500, detail=str(e))

    return {"message": "Plugboard reset successfully"}  # Return a ResetPlugboardResponse instance
