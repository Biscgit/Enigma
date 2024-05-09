import fastapi
import pytest

from server.lib import routes


def test_check_auth_exits():
    # setup
    token = "HELLO"
    user = "USER"
    routes.current_auth = {token: user}

    # test
    returned_user = routes.check_auth(token)

    # check
    assert user == returned_user


def test_check_auth_not_exists():
    # setup
    token = "HELLO"
    user = "USER"
    routes.current_auth = {}

    # test
    with pytest.raises(fastapi.HTTPException):
        _ = routes.check_auth(token)


def test_check_auth_incorrect():
    # setup
    token = "HELLO"
    user = "USER"
    routes.current_auth = {token: "OTHER_USER"}

    # test
    returned_user = routes.check_auth(token)

    # check
    assert user != returned_user
