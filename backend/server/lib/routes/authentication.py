__all__ = ["router", "check_auth"]

import logging
from uuid import uuid4
from hashlib import sha3_256

from fastapi import APIRouter, Depends, HTTPException, Security
from fastapi.security.api_key import APIKeyHeader
from server.lib.models import LoginForm
from server.lib.database import get_database, Database

router = APIRouter()
current_auth: dict[str, str] = {}
api_key_header = APIKeyHeader(name="Authorization", auto_error=False)


def check_auth(authorization: str = Security(api_key_header)) -> str:
    """checks auth for provided token and returns the username"""
    if authorization is None:
        raise HTTPException(status_code=401, detail="Authorization header missing")

    token_prefix = "Token "
    if not authorization.startswith(token_prefix):
        raise HTTPException(status_code=401, detail="Invalid token format")

    token = authorization[len(token_prefix) :]
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

        logging.info(f"User {login_form.username} has logged in.")
        return {"token": auth_token}

    else:
        raise HTTPException(status_code=401, detail="Invalid username or password")


@router.delete("/logout")
async def logout(username: str = Depends(check_auth)) -> dict:
    """Endpoint for logging out of the application"""
    global current_auth
    logging.info(f"User {username} has logged out.")
    current_auth = {key: val for key, val in current_auth.items() if val != username}
    return {"message": "OK"}
