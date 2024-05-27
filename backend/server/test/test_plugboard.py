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
        self.plugboards = {}

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
def mock_check_auth():
    return "test_user"


# Override the dependencies
app.dependency_overrides[check_auth] = mock_check_auth
app.dependency_overrides[get_database] = MockDatabase


@pytest.fixture
def client():
    return TestClient(app)


@pytest.mark.asyncio
async def test_configure_plugboard(client):
    response = await client.post("/plugboard/save",
                                 json={"plug_a": "a", "plug_b": "b", "machine": 1})
    assert response.status_code == 200
    data = response.json()
    assert "plugboard" in data
    assert isinstance(data["plugboard"], list)
    assert ["a", "b"] in data["plugboard"]


async def test_configure_plugboard(client):
    response = client.post("/plugboard/save",
                           json={"plug_a": "a", "plug_b": "b", "machine": 1})
    assert response.status_code == 200
    data = response.json()
    assert "plugboard" in data
    assert isinstance(data["plugboard"], list)
    assert ["a", "b"] in data["plugboard"]


async def test_get_configuration(client):
    # Set initial configuration
    client.post("/plugboard/save", json={"plug_a": "a", "plug_b": "b", "machine": 1})

    response = client.get("/plugboard/load?machine=1")
    assert response.status_code == 200
    data = response.json()
    assert "plugboard" in data
    assert isinstance(data["plugboard"], list)
    assert ["a", "b"] in data["plugboard"]


async def test_edit_plugboard(client):
    # Set initial configuration
    client.post("/plugboard/save", json={"plug_a": "a", "plug_b": "b", "machine": 1})

    response = client.put("/plugboard/edit",
                          json={"machine": 1, "letter": "a", "new_plug": {"plug_a": "c", "plug_b": "d"}})
    assert response.status_code == 200
    data = response.json()
    assert "plugboard" in data
    assert isinstance(data["plugboard"], list)
    assert ["c", "d"] in data["plugboard"]
    assert ["a", "b"] not in data["plugboard"]


async def test_reset_plugboard(client):
    # Set initial configuration
    client.post("/plugboard/save", json={"plug_a": "a", "plug_b": "b", "machine": 1})

    response = client.delete("/plugboard/reset?machine=1")
    assert response.status_code == 200

    # Check if plugboard is actually reset
    response = client.get("/plugboard/load?machine=1")
    assert response.status_code == 200
    data = response.json()
    assert "plugboard" in data
    assert data["plugboard"] == []



if __name__ == "__main__":
    pytest.main()
