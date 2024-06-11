from pydantic import BaseModel

__all__ = ["LoginForm"]


class LoginForm(BaseModel):
    username: str
    password: str


class Rotor(BaseModel):
    id: int
    rotor_position: str
    machine_type: int
    letter_shift: str
    scramble_alphabet: str
    machine_id: int
    place: int


class MinRotor(BaseModel):
    machine_id: int
    id: int
    template_i: int
    place: int
