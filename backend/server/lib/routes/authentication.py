__all__ = ["router", "check_auth"]

from uuid import uuid4
from hashlib import sha3_256

from fastapi import APIRouter, Depends, HTTPException
from server.lib.models import LoginForm
from server.lib.database import get_database, Database

router = APIRouter()
current_auth: dict[str, str] = {}


def check_auth(token: str) -> str:
    """checks auth for provided token and returns the username"""
    if token in current_auth:
        return current_auth[token]

    raise HTTPException(status_code=401, detail="Invalid token!")


@router.post("/login")
async def login(login_form: LoginForm, db_conn: "Database" = Depends(get_database)) -> dict[str, str]:
    """Endpoint for login. Returns an 256-bit token"""
    if await db_conn.check_login(login_form):
        auth_token: str = sha3_256(f"X{uuid4()}X{login_form.username}X".encode()).hexdigest()

        global current_auth

        # ensure only one token is handed out for each user
        current_auth = {k: v for k, v in current_auth.items() if not v == login_form.username}
        current_auth |= {auth_token: login_form.username}

        return {"token": auth_token}

    else:
        raise HTTPException(status_code=401, detail="Invalid username or password")


@router.delete("/logout")
async def logout(token: str, _: str = Depends(check_auth)) -> dict:
    """Endpoint for logging out of the application"""
    current_auth.pop(token)
    return {"message": "OK"}
