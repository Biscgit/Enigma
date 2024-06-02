import pytest
from fastapi.testclient import TestClient
from fastapi import FastAPI, Depends, HTTPException
from server.lib.routes.plugboard import router
from server.lib.database import Database, get_database
from server.lib.routes.authentication import check_auth
from pydantic import BaseModel

# Create a TestApp to include the router
app = FastAPI()
app.include_router(router)

# Mock Database dependency
class MockDatabase(Database):
    def __init__(self):
        self.plugboards = {('test_user', 1): [['a', 'b']]}

    async def get_plugboards(self, username, machine):
        return self.plugboards.get((username, machine), [])

    async def save_plugboard(self, username, machine, plug_a, plug_b):
        if (username, machine) not in self.plugboards:
            self.plugboards[(username, machine)] = []
        self.plugboards[(username, machine)].append([plug_a, plug_b])

    async def remove_plugboard(self, username, machine, key_1, key_2):
        if (username, machine) in self.plugboards:
            self.plugboards[(username, machine)] = [
                pair for pair in self.plugboards[(username, machine)]
                if not (key_1 in pair or key_2 in pair)
            ]

class PlugboardResponse(BaseModel):
    message: str

# Mock authentication dependency
def override_check_auth(username="test_user"):
    return username

# Override dependencies
app.dependency_overrides[get_database] = MockDatabase
app.dependency_overrides[check_auth] = override_check_auth

@pytest.fixture
def client():
    return TestClient(app)

def test_configure_plugboard(client):
    response = client.post("/plugboard/save?machine=1",
                           json={"plug_a": "c", "plug_b": "d"})
    assert response.status_code == 200
    data = response.json()
    assert "plugboard" in data
    assert isinstance(data["plugboard"], list)
    assert ["c", "d"] in data["plugboard"]

def test_get_configuration(client):
    response = client.get("/plugboard/load", params={"machine": 1})
    assert response.status_code == 200
    data = response.json()
    assert "plugboard" in data
    assert isinstance(data["plugboard"], list)
    assert ['a', 'b'] in data["plugboard"]

def test_edit_plugboard(client):
    response = client.put("/plugboard/edit?machine=1&letter=a",
                          json={"plug_a": "c", "plug_b": "d"})
    assert response.status_code == 404
    data = response.json()
    assert "detail" in data
    assert "Letter does not exist in the plugboard" in data["detail"]

def test_reset_plugboard(client):
    response = client.delete("/plugboard/reset", params={"machine": 1, "key_1": "a", "key_2": "b"})
    assert response.status_code == 200
    data = response.json()
    assert "message" in data
    assert data["message"] == "Plugboard reset successfully"

if __name__ == "__main__":
    pytest.main()
