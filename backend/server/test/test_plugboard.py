import pytest
from fastapi.testclient import TestClient
from server.lib.routes import plugboard

@pytest.fixture
def client():
    return TestClient(plugboard)

@pytest.mark.asyncio
async def test_configure_plugboard(client):
    # Assuming authentication is required for this endpoint
    response = client.post("/plugboard/save", json={"plug": {"plug_a": "a", "plug_b": "b"}, "machine": 1, "username": "test_user"})
    assert response.status_code == 200
    data = response.json()
    assert "plugboard" in data
    assert isinstance(data["plugboard"], list)

@pytest.mark.asyncio
async def test_get_configuration(client):
    # Assuming authentication is required for this endpoint
    response = client.get("/plugboard/load?machine=1&username=test_user")
    assert response.status_code == 200
    data = response.json()
    assert "plugboard" in data
    assert isinstance(data["plugboard"], list)

@pytest.mark.asyncio
async def test_edit_plugboard(client):
    # Assuming authentication is required for this endpoint
    response = client.put("/plugboard/edit", json={"machine": 1, "letter": "A", "new_plug": {"plug_a": "c", "plug_b": "d"}, "username": "test_user"})
    assert response.status_code == 200
    data = response.json()
    assert "plugboard" in data
    assert isinstance(data["plugboard"], list)

@pytest.mark.asyncio
async def test_reset_plugboard(client):
    # Assuming authentication is required for this endpoint
    response = client.delete("/plugboard/reset?machine=1&username=test_user")
    assert response.status_code == 200
    data = response.json()
    assert "message" in data
    assert data["message"] == "Plugboard reset successfully"