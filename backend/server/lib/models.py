from pydantic import BaseModel

__all__ = ["LoginForm"]


class LoginForm(BaseModel):
    username: str
    password: str
