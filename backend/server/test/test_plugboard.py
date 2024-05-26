import pytest
from fastapi.testclient import TestClient
from server.lib.routes import plugboard

client = TestClient(plugboard)


@pytest.mark.asyncio
async def test_configure_plugboard():
    # Test successful plugboard configuration
    response = await client.post(
        "/plugboard/save",
        json={"plug": {"plug_a": "a", "plug_b": "b"}, "machine": 1, "username": "test_user"}
    )
    assert response.status_code == 200
    assert response.json() == {"plugboard": [["a", "b"]]}

    # Test too many plugboard configurations
    for _ in range(10):
        await client.post(
            "/plugboard/save",
            json={"plug": {"plug_a": "a", "plug_b": "b"}, "machine": 1, "username": "test_user"}
        )
    response = await client.post(
        "/plugboard/save",
        json={"plug": {"plug_a": "c", "plug_b": "d"}, "machine": 1, "username": "test_user"}
    )
    assert response.status_code == 400


@pytest.mark.asyncio
async def test_get_configuration():
    response = await client.get("/plugboard/load?machine=1&username=test_user")
    assert response.status_code == 200
    assert response.json() == {"plugboard": [["a", "b"]]}


@pytest.mark.asyncio
async def test_edit_plugboard():
    # Test successful edit of plugboard
    response = await client.put(
        "/plugboard/edit",
        json={"letter": "a", "new_plug": {"plug_a": "c", "plug_b": "d"}, "machine": 1, "username": "test_user"}
    )
    assert response.status_code == 200
    assert response.json() == {"plugboard": [["c", "d"]]}

    # Test letter not found
    response = await client.put(
        "/plugboard/edit",
        json={"letter": "x", "new_plug": {"plug_a": "c", "plug_b": "d"}, "machine": 1, "username": "test_user"}
    )
    assert response.status_code == 404


@pytest.mark.asyncio
async def test_reset_plugboard():
    response = await client.delete("/plugboard/reset?machine=1&username=test_user")
    assert response.status_code == 200
    assert response.json() == {"message": "Plugboard reset successfully"}
