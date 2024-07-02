import pytest

from server.lib.models import check_len


def test_check_len_wrong_chars():
    value = "frgwduzv41"
    with pytest.raises(ValueError):
        check_len(value, 0, 99, "")


def test_check_len_too_long():
    max_length = 5
    long_text = "defbueoifbeiw"
    with pytest.raises(ValueError):
        check_len(long_text, 0, max_length, "")


def test_check_len_wrong_value():
    value = True
    with pytest.raises(ValueError):
        check_len(value, 0, 99, "")
