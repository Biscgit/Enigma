import uuid
from fastapi.testclient import TestClient
from unittest.mock import MagicMock

from server.app import app
from server.lib import database, models, routes

client = TestClient(app)


def override_get_database():
    """overrides database with a mock for unit-testing"""

    class MockDatabase:
        users = {
            "user1": "password1",
            "user2": "password2",
        }

        @staticmethod
        async def check_login(form: models.LoginForm) -> bool:
            users = MockDatabase.users

            if form.username in users:
                if users[form.username] == form.password:
                    return True

            return False


app.dependency_overrides[database.get_database] = override_get_database
uuid.uuid4 = MagicMock(return_value="uuid-mock-string")

user_token1 = "ff7b6b5c3bb186091b41eb1a1c057d30f70e0b9566d8303c60d17f71b9b51c24"
user_token2 = "3eb468c87f54151037964eea70a969ee251e7960629a84274c31d5c412b684a6"


def test_login_valid_user():
    uuid.uuid4 = MagicMock(return_value="uuid-mock-string")

    # setup
    user = models.LoginForm.model_construct(username="user1", password="password1")
    routes.current_auth = {}

    # test
    response = client.post(f"/login", content=user.model_dump_json())

    # check
    assert response.status_code == 200
    assert response.json() == {"token": user_token1}
    assert routes.current_auth == {user_token1: "user1"}


def test_login_unknown_user():
    # setup
    user = models.LoginForm.model_construct(username="user12345", password="no-pass")
    routes.current_auth = {}

    # test
    response = client.post(f"/login", content=user.model_dump_json())

    # check
    assert response.status_code == 401
    assert response.json() == {"detail": "Invalid token!"}
    assert routes.current_auth == {}


def test_login_invalid_password():
    # setup
    user = models.LoginForm.model_construct(username="user1", password="wrong-password")
    routes.current_auth = {"dummy-token": "dummy-user"}

    # test
    response = client.post(f"/login", content=user.model_dump_json())

    # check
    assert response.status_code == 401
    assert response.json() == {"detail": "Invalid username or password"}
    assert routes.current_auth == {"dummy-token": "dummy-user"}


def test_login_other_password():
    # setup
    user = models.LoginForm.model_construct(username="user2", password="password1")
    routes.current_auth = {}

    # test
    response = client.post(f"/login", content=user.model_dump_json())

    # check
    assert response.status_code == 401
    assert response.json() == {"detail": "Invalid username or password"}
    assert routes.current_auth == {}


def test_login_already_auth():
    # setup
    user = models.LoginForm.model_construct(username="user2", password="password2")
    routes.current_auth = {"demo-token": "user1"}
    expected_token = user_token2

    # test
    response = client.post(f"/login", content=user.model_dump_json())

    # check
    assert response.status_code == 401
    assert response.json() == {"detail": "Invalid username or password"}
    assert routes.current_auth == {expected_token: "user2"}


def test_different_logins():
    # setup
    user1 = models.LoginForm.model_construct(username="user1", password="password1")
    user2 = models.LoginForm.model_construct(username="user2", password="password2")
    routes.current_auth = {}

    # test
    response1 = client.post(f"/login", content=user1.model_dump_json())
    response2 = client.post(f"/login", content=user2.model_dump_json())

    # check
    assert response1.status_code == 200
    assert response2.status_code == 200
    assert response1.json() == {"token": user_token1}
    assert response2.json() == {"token": user_token2}
    assert routes.current_auth == {user_token1: "user1", user_token2: "user2"}
