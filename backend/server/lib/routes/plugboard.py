from fastapi import FastAPI, HTTPException, Depends
from pydantic import BaseModel, validator
from typing import List, Dict
from server.lib.database import Database, get_database

app = FastAPI()
MAX_PLUGS = 10


# Pydantic model for plug configurations
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


# Dependency injection for database
def get_db():
    return get_database()


@app.on_event("startup")
async def startup():
    db = get_db()
    await db.connect()


@app.on_event("shutdown")
async def shutdown():
    db = get_db()
    await db.disconnect()


@app.post("/configure/", response_model=dict)
async def configure_plugboard(plug: PlugConfig, db: Database = Depends(get_db)):
    plugs = await db.get_plugboards(plug.username, plug.machine_id)
    if len(plugs) >= MAX_PLUGS:
        raise HTTPException(status_code=400, detail="Too many plugboard configurations")

    plug_a_upper = plug.plug_a.upper()
    plug_b_upper = plug.plug_b.upper()

    for existing_plug in plugs:
        if plug_a_upper in existing_plug or plug_b_upper in existing_plug:
            raise HTTPException(status_code=400, detail="Duplicate letter detected")

    await db.save_plugboard(plug.username, plug.machine_id, plug_a_upper, plug_b_upper)
    return {"message": "Plugboard configured successfully", "plugboard": plugs}


@app.get("/config/{username}/{machine_id}", response_model=dict)
async def get_configuration(username: str, machine_id: int, db: Database = Depends(get_db)):
    try:
        plugs = await db.get_plugboards(username, machine_id)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

    return {"plugboard": plugs}


@app.put("/edit/{username}/{machine_id}/{letter}", response_model=dict)
async def edit_plugboard(username: str, machine_id: int, letter: str, new_plug: PlugConfig, db: Database = Depends(get_db)):
    letter_upper = letter.upper()
    plugs = await db.get_plugboards(username, machine_id)

    if letter_upper not in [p[0] for p in plugs]:
        raise HTTPException(status_code=404, detail="Letter does not exist in the plugboard")

    old_plug = next(p for p in plugs if p[0] == letter_upper)

    new_plug_a_upper = new_plug.plug_a.upper()
    new_plug_b_upper = new_plug.plug_b.upper()

    for existing_plug in plugs:
        if new_plug_a_upper in existing_plug or new_plug_b_upper in existing_plug:
            raise HTTPException(status_code=400, detail="Duplicate letter detected")

    await db.remove_plugboard(username, machine_id, old_plug[0], old_plug[1])
    await db.save_plugboard(username, machine_id, new_plug_a_upper, new_plug_b_upper)
    return {"message": "Plugboard updated successfully", "plugboard": plugs}


@app.delete("/reset/{username}/{machine_id}", response_model=dict)
async def reset_plugboard(username: str, machine_id: int, db: Database = Depends(get_db)):
    try:
        await db.reset_plugboard(username, machine_id)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

    return {"message": "Plugboard reset successfully"}
