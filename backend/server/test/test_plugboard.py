import copy

import pytest
from fastapi.testclient import TestClient
from fastapi import FastAPI
from server.lib.routes.plugboard import router
from server.lib.database import get_database
from server.lib.routes.authentication import check_auth
from server.lib.plugboard import switch_letter
from pydantic import BaseModel

# Create a TestApp to include the router
app = FastAPI()
app.include_router(router)

pytest_plugins = ('pytest_asyncio',)


# Mock Database dependency
class MockDatabase:
    def __init__(self):
        self.plugboards = {('test_user', 1): [['a', 'b']]}

    @staticmethod
    def empty():
        cls = MockDatabase()
        cls.plugboards = {('test_user', 1): []}
        return cls

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

    @staticmethod
    async def is_plugboard_enabled(*_) -> bool:
        return True


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
    response = client.post("/plugboard/save?machine=1&plug_a=c&plug_b=d")
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


"""def test_edit_plugboard(client):
    response = client.put("/plugboard/edit?machine=1&letter=a",
                          json={"plug_a": "c", "plug_b": "d"})
    assert response.status_code == 404
    data = response.json()
    assert "detail" in data
    assert "Letter does not exist in the plugboard" in data["detail"]
"""

def test_reset_plugboard(client):
    response = client.delete("/plugboard/remove", params={"machine": 1, "plug_a": "a", "plug_b": "b"})
    assert response.status_code == 200
    data = response.json()
    assert "message" in data
    assert data["message"] == "Plugboard reset successfully"


@pytest.mark.asyncio
async def test_plugboard_switch():
    """test the switching of letters in both directions"""
    db = MockDatabase.empty()

    new_app = copy.copy(app)
    new_app.dependency_overrides[get_database] = lambda: db
    new_app.dependency_overrides[check_auth] = override_check_auth
    client = TestClient(new_app)

    letters = ["a", "l", "d", "g", "a", "i", "p", "h", "e", "i", "m"]
    expected = ["a", "l", "d", "g", "a", "i", "p", "h", "e", "i", "m"]
    for l, e in zip(letters, expected):
        new = await switch_letter("test_user", 1, l, db)
        assert new == e

    r = client.post("/plugboard/save?machine=1&plug_a=c&plug_b=d")
    assert r.status_code == 200
    r = client.post("/plugboard/save?machine=1&plug_a=g&plug_b=h")
    assert r.status_code == 200
    r = client.post("/plugboard/save?machine=1&plug_a=p&plug_b=w")
    assert r.status_code == 200
    assert db.plugboards == {('test_user', 1): [['c', 'd'], ['g', 'h'], ['p', 'w']]}

    letters = ["a", "l", "d", "g", "a", "i", "w", "h", "e", "c", "m"]
    expected = ["a", "l", "c", "h", "a", "i", "p", "g", "e", "d", "m"]
    for l, e in zip(letters, expected):
        new = await switch_letter("test_user", 1, l, db)
        assert new == e

    r = client.delete("/plugboard/remove", params={"machine": 1, "plug_a": "p", "plug_b": "w"})
    assert r.status_code == 200
    r = client.delete("/plugboard/remove", params={"machine": 1, "plug_a": "d", "plug_b": "c"})
    assert r.status_code == 200

    letters = ["a", "l", "d", "g", "a", "i", "w", "h", "e", "c", "m"]
    expected = ["a", "l", "d", "h", "a", "i", "w", "g", "e", "c", "m"]
    for l, e in zip(letters, expected):
        new = await switch_letter("test_user", 1, l, db)
        assert new == e
