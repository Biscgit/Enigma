__all__ = ["router"]

import logging
from uuid import uuid4
from hashlib import sha3_256

from fastapi import APIRouter, Depends, HTTPException
from .models import LoginForm
from .database import get_database, Database

router = APIRouter()
current_auth: dict[str, str] = {}


@router.post("/login")
async def login(login_form: LoginForm, db_conn: "Database" = Depends(get_database)) -> dict[str, str]:
    """Endpoint for login. Returns an 256-bit token"""
    if await db_conn.check_login(login_form):
        auth_token: str = sha3_256(f"X{uuid4()}X{login_form.username}X".encode()).hexdigest()

        global current_auth
        current_auth |= {login_form.username: auth_token}

        return {"token": auth_token}

    else:
        raise HTTPException(status_code=401, detail="Invalid username or password")
