import pytest

from server.lib import models


def test_check_len_wrong_chars():
    value = "frgwduzv41"
    with pytest.raises(ValueError):
        models.check_len(value, 0, 99, "")


def test_check_len_too_long():
    max_length = 5
    long_text = "defbueoifbeiw"
    with pytest.raises(ValueError):
        models.check_len(long_text, 0, max_length, "")


def test_check_len_wrong_value():
    value = True
    with pytest.raises(ValueError):
        models.check_len(value, 0, 99, "")


def test_validator_update_rotor():
    model = models.UpdateRotor(
        rotor_position="T",
        offset_value=5,
        id=42
    )
    assert model.rotor_position == "t"


def test_validator_machine():
    model = models.Machine(
        name="k",
        plugboard=True,
        number_rotors=6,
        rotors=[],
        reflectors=[]
    )
    assert model.number_rotors == 6


def test_validator_machine_limit():
    with pytest.raises(ValueError):
        _ = models.Machine(
            name="k",
            plugboard=True,
            number_rotors=100,
            rotors=[],
            reflectors=[]
        )
