import pytest
from httpx import AsyncClient, ASGITransport

from server.app import app
from server.lib import routes

pytest_plugins = ('pytest_asyncio',)


@pytest.mark.asyncio
async def test_logout_valid_token():
    # setup
    token = "token-12345-xxx"
    routes.current_auth = {token: "testuser"}

    # test
    async with AsyncClient(transport=ASGITransport(app), base_url="http://test") as ac:
        response = await ac.delete(f"/logout", params={"token": token})

    # check
    assert response.status_code == 200
    assert response.json() == {"message": "OK"}
    assert routes.current_auth == {}


@pytest.mark.asyncio
async def test_logout_invalid_token():
    # setup
    token = "token-12345-xxx"
    invalid_token = "token-invalid!"
    routes.current_auth = {token: "testuser"}

    # test
    async with AsyncClient(transport=ASGITransport(app), base_url="http://test") as ac:
        response = await ac.delete(f"/logout", params={"token": invalid_token})

    # check
    assert response.status_code == 401
    assert response.json() == {"detail": "Invalid token!"}
    assert routes.current_auth == {token: "testuser"}
