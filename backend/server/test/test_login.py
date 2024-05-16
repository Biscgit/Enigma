import pytest
from httpx import AsyncClient, ASGITransport

from server.app import app
from server.lib import database, models
from server.lib.routes import authentication

pytest_plugins = ('pytest_asyncio',)


@pytest.fixture
def mocked_uuid(mocker):
    # Patching uuid.uuid4() to return a constant string
    mocked_uuid = mocker.patch('server.lib.authentication.uuid4', return_value="uuid-mock-string-0000")
    return mocked_uuid


user_token1 = "594a6a5b2b210a3e2024cc4f2a17caac4c838815c74868931dbde95cded1741d"
user_token2 = "3a8c8e03f22aebe85cfdd757dccfe91ab737d915bc135e436806dc916a11291e"


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

    return MockDatabase


app.dependency_overrides[database.get_database] = override_get_database


@pytest.mark.asyncio
async def test_login_valid_user(mocked_uuid):
    # setup
    user = models.LoginForm.model_construct(username="user1", password="password1")
    authentication.current_auth = {}

    # test
    async with AsyncClient(transport=ASGITransport(app), base_url="http://test") as ac:
        response = await ac.post(f"/login", content=user.model_dump_json())

    # check
    assert response.status_code == 200
    assert response.json() == {"token": user_token1}
    assert authentication.current_auth == {user_token1: "user1"}


@pytest.mark.asyncio
async def test_login_unknown_user(mocked_uuid):
    # setup
    user = models.LoginForm.model_construct(username="user12345", password="no-pass")
    authentication.current_auth = {}

    # test
    async with AsyncClient(transport=ASGITransport(app), base_url="http://test") as ac:
        response = await ac.post(f"/login", content=user.model_dump_json())

    # check
    assert response.status_code == 401
    assert response.json() == {"detail": "Invalid username or password"}
    assert authentication.current_auth == {}


@pytest.mark.asyncio
async def test_login_invalid_password(mocked_uuid):
    # setup
    user = models.LoginForm.model_construct(username="user1", password="wrong-password")
    authentication.current_auth = {"dummy-token": "dummy-user"}

    # test
    async with AsyncClient(transport=ASGITransport(app), base_url="http://test") as ac:
        response = await ac.post(f"/login", content=user.model_dump_json())

    # check
    assert response.status_code == 401
    assert response.json() == {"detail": "Invalid username or password"}
    assert authentication.current_auth == {"dummy-token": "dummy-user"}


@pytest.mark.asyncio
async def test_login_other_password(mocked_uuid):
    # setup
    user = models.LoginForm.model_construct(username="user2", password="password1")
    authentication.current_auth = {}

    # test
    async with AsyncClient(transport=ASGITransport(app), base_url="http://test") as ac:
        response = await ac.post(f"/login", content=user.model_dump_json())

    # check
    assert response.status_code == 401
    assert response.json() == {"detail": "Invalid username or password"}
    assert authentication.current_auth == {}


@pytest.mark.asyncio
async def test_login_already_auth(mocked_uuid):
    # setup
    user = models.LoginForm.model_construct(username="user2", password="password2")
    authentication.current_auth = {"demo-token": "user2"}
    expected_token = user_token2

    # test
    async with AsyncClient(transport=ASGITransport(app), base_url="http://test") as ac:
        response = await ac.post(f"/login", content=user.model_dump_json())

    # check
    assert response.status_code == 200
    assert response.json() == {"token": expected_token}
    assert authentication.current_auth == {expected_token: "user2"}


@pytest.mark.asyncio
async def test_different_logins(mocked_uuid):
    # setup
    user1 = models.LoginForm.model_construct(username="user1", password="password1")
    user2 = models.LoginForm.model_construct(username="user2", password="password2")
    authentication.current_auth = {}

    # test
    async with AsyncClient(transport=ASGITransport(app), base_url="http://test") as ac:
        response1 = await ac.post(f"/login", content=user1.model_dump_json())
        response2 = await ac.post(f"/login", content=user2.model_dump_json())

    # check
    assert response1.status_code == 200
    assert response2.status_code == 200
    assert response1.json() == {"token": user_token1}
    assert response2.json() == {"token": user_token2}
    assert authentication.current_auth == {user_token1: "user1", user_token2: "user2"}
