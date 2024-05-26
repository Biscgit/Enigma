from fastapi.testclient import TestClient
from unittest.mock import AsyncMock, MagicMock
from server.lib.database import Database
from server.lib.routes import plugboard

client = TestClient(plugboard)


def test_configure_plugboard():
    fake_plug = {"plug_a": "a", "plug_b": "b"}
    fake_db = MagicMock(Database)
    fake_db.get_plugboards.return_value = []
    fake_db.save_plugboard.return_value = None

    response = client.post("/plugboard/save", json=fake_plug)
    assert response.status_code == 200
    assert response.json() == {"plugboard": []}


def test_get_configuration():
    fake_db = MagicMock(Database)
    fake_db.get_plugboards.return_value = [["a", "b"], ["c", "d"]]

    response = client.get("/plugboard/load")
    assert response.status_code == 200
    assert response.json() == {"plugboard": [["a", "b"], ["c", "d"]]}


def test_edit_plugboard():
    fake_new_plug = {"plug_a": "c", "plug_b": "d"}
    fake_db = MagicMock(Database)
    fake_db.get_plugboards.return_value = [["a", "b"], ["c", "d"]]
    fake_db.remove_plugboard.return_value = None
    fake_db.save_plugboard.return_value = None

    response = client.put("/plugboard/edit?letter=A", json=fake_new_plug)
    assert response.status_code == 200
    assert response.json() == {"plugboard": [["c", "d"], ["c", "d"]]}


def test_reset_plugboard():
    fake_db = MagicMock(Database)
    fake_db.reset_plugboard.return_value = None

    response = client.delete("/plugboard/reset")
    assert response.status_code == 200
    assert response.json() == {"message": "Plugboard reset successfully"}
