from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Dict

from server.lib.database import get_database

app = FastAPI()
database = get_database()

MAX_PLUGS = 10

plugboard: Dict[str, str] = {}


# Define a Pydantic model for plug configurations
class PlugConfig(BaseModel):
    plug_a: str
    plug_b: str

    @classmethod
    def validate_letters(cls, v):
        if len(v) != 1 or not v.isalpha():
            raise ValueError("Letters must be alphabetic")
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
    # Check if maximum number of plugs has been reached
    if len(plugboard) >= MAX_PLUGS * 2:
        raise HTTPException(status_code=400, detail="Too many plugboards")

    plug_a_upper = plug.plug_a
    plug_b_upper = plug.plug_b

    if plug_a_upper in plugboard or plug_b_upper in plugboard:
        raise HTTPException(status_code=400, detail="Duplicate letter detected")

    plugboard[plug_a_upper] = plug_b_upper
    plugboard[plug_b_upper] = plug_a_upper

    # Save to database
    try:
        await database.save_plugboard("default_user", 1, plug_a_upper, plug_b_upper)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

    return {"message": "Plugboard configured successfully", "plugboard": plugboard}


# Define endpoint to retrieve current plugboard configuration
@app.get("/config/")
async def get_configuration():
    # Load from database
    try:
        plugs = await database.get_plugboards("default_user", 1)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

    return {"plugboard": plugs}


# Define endpoint to edit plugboard configuration
@app.put("/edit/{letter}")
async def edit_plugboard(letter: str, new_plug: PlugConfig):
    letter_upper = letter.upper()

    if letter_upper not in plugboard:
        raise HTTPException(status_code=404, detail="Letter does not exist")

    # Remove the old plug configuration
    old_plug = plugboard.pop(letter_upper)
    plugboard.pop(old_plug, None)

    new_plug_a_upper = new_plug.plug_a.upper()
    new_plug_b_upper = new_plug.plug_b.upper()

    # Check for duplicate letters in plugboard
    if new_plug_a_upper in plugboard or new_plug_b_upper in plugboard:
        raise HTTPException(status_code=400, detail="Duplicate letter detected")

    # Update plugboard configuration
    plugboard[new_plug_a_upper] = new_plug_b_upper
    plugboard[new_plug_b_upper] = new_plug_a_upper

    # Update the database
    try:
        await database.remove_plugboard("default_user", 1, letter_upper, old_plug)
        await database.save_plugboard("default_user", 1, new_plug_a_upper, new_plug_b_upper)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

    return {"message": "Plugboard updated successfully", "plugboard": plugboard}


# Define endpoint to reset plugboard configuration
@app.delete("/reset/")
async def reset_plugboard():
    plugboard.clear()
    return {"message": "Plugboard reset successfully"}
