from pydantic import BaseModel, root_validator, validator
from typing import Optional
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

    @root_validator(pre=True)
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


class Rotor(MinRotor):
    rotor_position: str
    machine_type: int
    letter_shift: str
    rotor_position: str
    scramble_alphabet: str
    template_id: Optional[str] = None

    @validator("scramble_alphabet")
    def check_alphabet(cls, value):
        check_len(value, 26, 26, "Custom Alphabet")
        return value.lower()

    @validator("rotor_position")
    def check_pos(cls, value):
        check_len(value, 1, 1, "rotor_position")
        return value.lower()

    @validator("letter_shift")
    def check_notch(cls, value):
        check_len(value, 1, 2, "letter_shift")
        return value.lower()
