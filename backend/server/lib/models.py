from pydantic import BaseModel, model_validator, field_validator
from typing import Optional, List
import string

__all__ = ["LoginForm"]

alphabet = string.ascii_lowercase


class LoginForm(BaseModel):
    username: str
    password: str


class MinRotor(BaseModel):
    id: int
    machine_id: int
    template_id: int
    place: int
    number: int
    is_rotate: Optional[bool] = True

    @model_validator(pre=True)
    def id_must_be_positive(cls, values):
        for key, value in values.items():
            if isinstance(value, int):
                if value < 0:
                    raise ValueError(f"{key} must be positive")
        return values


def check_len(value: str, min: int, max: int, key: str) -> None:
    if len(value) < min or len(value) > max:
        raise ValueError(f"{key} must be between {min} and {max} characters long")

    if not isinstance(value, str):
        raise ValueError(f"{key} must be an alphabetical value")
    for i in value:
        if i.lower() not in alphabet:
            raise ValueError(f"{key} must be an alphabetical value")


class UpdateRotor(BaseModel):
    rotor_position: str
    offset_value: int
    id: int

    @field_validator("rotor_position")
    def check_pos(cls, value):
        check_len(value, 1, 1, "rotor_position")
        return value.lower()


class Machine(BaseModel):
    name: str
    plugboard: bool
    number_rotors: int
    rotors: List[int]
    reflectors: List[str]

    @field_validator("number_rotors")
    def check_int(cls, value):
        if 0 < value < 100:
            return value

        raise ValueError("Number Rotors must be between 1 and 99!")
