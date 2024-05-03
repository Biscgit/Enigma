from fastapi.testclient import TestClient

from server.app import app
from server.lib import routes

client = TestClient(app)


def test_logout_valid_token():
    # setup
    token = "token-12345-xxx"
    routes.current_auth = {token: "testuser"}

    # test
    response = client.delete(f"/logout", params={"token": token})

    # check
    assert response.status_code == 200
    assert response.json() == {"message": "OK"}
    assert routes.current_auth == {}


def test_logout_invalid_token():
    # setup
    token = "token-12345-xxx"
    invalid_token = "token-invalid!"
    routes.current_auth = {token: "testuser"}

    # test
    response = client.delete(f"/logout", params={"token": invalid_token})

    # check
    assert response.status_code == 401
    assert response.json() == {"detail": "Invalid token!"}
    assert routes.current_auth == {token: "testuser"}
