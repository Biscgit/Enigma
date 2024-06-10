from pydantic import BaseModel

__all__ = ["LoginForm"]


class LoginForm(BaseModel):
    username: str
    password: str


class Rotor(BaseModel):
    id: int
    rotor_position: str
    letter_shift: str
    scramble_alphabet: str
    machine_id: int
