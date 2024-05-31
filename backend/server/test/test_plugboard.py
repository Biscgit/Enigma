import pytest
from fastapi.testclient import TestClient
from server.lib.routes.plugboard import router
from server.lib.database import Database, get_database
from server.lib.routes.authentication import check_auth
from fastapi import FastAPI, Depends

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

    async def remove_plugboard(self, username, machine, plug_a, plug_b):
        if (username, machine) in self.plugboards:
            self.plugboards[(username, machine)] = [
                pair for pair in self.plugboards[(username, machine)]
                if not (plug_a in pair or plug_b in pair)
            ]

    async def reset_plugboard(self, username, machine):
        self.plugboards[(username, machine)] = []


# Mock authentication dependency
def override_check_auth(username="test12345"):
    return "token-12345-xxx"



@pytest.fixture
def client():
    return TestClient(app)


def test_configure_plugboard(client, monkeypatch):
    monkeypatch.setattr("server.lib.routes.authentication.check_auth", override_check_auth)

    response = client.post("/plugboard/save?token=token-12345-xxx",
                           json={"plug_a": "c", "plug_b": "d", "machine": 1})
    assert response.status_code == 401
    data = response.json()
    assert "plugboard" in data
    assert isinstance(data["plugboard"], list)
    assert ["c", "d"] in data["plugboard"]

def test_get_configuration(client, monkeypatch):
    monkeypatch.setattr("server.lib.routes.authentication.check_auth", override_check_auth)

    response = client.get("/plugboard/load?token=token-12345-xxx", params={"machine": 1})
    assert response.status_code == 401
    data = response.json()
    assert "plugboard" in data
    assert isinstance(data["plugboard"], list)
    assert ['a', 'b'] in data["plugboard"]

def test_edit_plugboard(client, monkeypatch):
    monkeypatch.setattr("server.lib.routes.authentication.check_auth", override_check_auth)

    response = client.put("/plugboard/edit?token=token-12345-xxx",
                          json={"machine": 1, "letter": "a", "new_plug": {"plug_a": "c", "plug_b": "d"}})
    assert response.status_code == 401
    data = response.json()
    assert "plugboard" in data
    assert isinstance(data["plugboard"], list)
    assert ["c", "d"] in data["plugboard"]
    assert ["a", "b"] not in data["plugboard"]

def test_reset_plugboard(client, monkeypatch):
    monkeypatch.setattr("server.lib.routes.authentication.check_auth", override_check_auth)

    response = client.delete("/plugboard/reset?token=token-12345-xxx", params={"machine": 1})
    assert response.status_code == 401
    data = response.json()
    assert "message" in data
    assert data["message"] == "Plugboard reset successfully"

    # Check if plugboard is actually reset
    response = client.get("/plugboard/load?token=token-12345-xxx", params={"machine": 1})
    assert response.status_code == 401
    data = response.json()
    assert "plugboard" in data
    assert data["plugboard"] == []


if __name__ == "__main__":
    pytest.main()
