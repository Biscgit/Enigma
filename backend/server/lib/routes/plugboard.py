from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, validator
from typing import Dict
from server.lib.database import get_database

app = FastAPI()
database = get_database()

MAX_PLUGS = 10

plugboard: Dict[str, Dict[int, Dict[str, str]]] = {}


# Define a Pydantic model for plug configurations
class PlugConfig(BaseModel):
    plug_a: str
    plug_b: str
    username: str
    machine_id: int

    @validator('plug_a', 'plug_b')
    def validate_letters(cls, v):
        if len(v) != 1 or not v.isalpha():
            raise ValueError("Letters must be a single alphabetic character")
        return v.upper()


@app.on_event("startup")
async def startup():
    await database.connect()


@app.on_event("shutdown")
async def shutdown():
    await database.disconnect()


# Define endpoint to configure the plugboard
@app.post("/configure/")
async def configure_plugboard(plug: PlugConfig):
    user_plugboard = plugboard.setdefault(plug.username, {})
    machine_plugboard = user_plugboard.setdefault(plug.machine_id, {})

    if len(machine_plugboard) >= MAX_PLUGS * 2:
        raise HTTPException(status_code=400, detail="Too many plugboard configurations")

    plug_a_upper = plug.plug_a.upper()
    plug_b_upper = plug.plug_b.upper()

    if plug_a_upper in machine_plugboard or plug_b_upper in machine_plugboard:
        raise HTTPException(status_code=400, detail="Duplicate letter detected")

    machine_plugboard[plug_a_upper] = plug_b_upper
    machine_plugboard[plug_b_upper] = plug_a_upper

    # Save to database
    try:
        await database.save_plugboard(plug.username, plug.machine_id, plug_a_upper, plug_b_upper)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

    return {"message": "Plugboard configured successfully", "plugboard": machine_plugboard}


# Define endpoint to retrieve current plugboard configuration
@app.get("/config/{username}/{machine_id}")
async def get_configuration(username: str, machine_id: int):
    # Load from database
    try:
        plugs = await database.get_plugboards(username, machine_id)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

    return {"plugboard": plugs}


# Define endpoint to edit plugboard configuration
@app.put("/edit/{username}/{machine_id}/{letter}")
async def edit_plugboard(username: str, machine_id: int, letter: str, new_plug: PlugConfig):
    letter_upper = letter.upper()
    user_plugboard = plugboard.get(username, {})
    machine_plugboard = user_plugboard.get(machine_id, {})

    if letter_upper not in machine_plugboard:
        raise HTTPException(status_code=404, detail="Letter does not exist in the plugboard")

    # Remove the old plug configuration
    old_plug = machine_plugboard.pop(letter_upper)
    machine_plugboard.pop(old_plug, None)

    new_plug_a_upper = new_plug.plug_a.upper()
    new_plug_b_upper = new_plug.plug_b.upper()

    # Check for duplicate letters in plugboard
    if new_plug_a_upper in machine_plugboard or new_plug_b_upper in machine_plugboard:
        raise HTTPException(status_code=400, detail="Duplicate letter detected")

    # Update plugboard configuration
    machine_plugboard[new_plug_a_upper] = new_plug_b_upper
    machine_plugboard[new_plug_b_upper] = new_plug_a_upper

    # Update the database
    try:
        await database.remove_plugboard(username, machine_id, letter_upper, old_plug)
        await database.save_plugboard(username, machine_id, new_plug_a_upper, new_plug_b_upper)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

    return {"message": "Plugboard updated successfully", "plugboard": machine_plugboard}


# Define endpoint to reset plugboard configuration
@app.delete("/reset/{username}/{machine_id}")
async def reset_plugboard(username: str, machine_id: int):
    user_plugboard = plugboard.get(username, {})
    user_plugboard[machine_id] = {}

    try:
        await database.reset_plugboard(username, machine_id)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

    return {"message": "Plugboard reset successfully"}
