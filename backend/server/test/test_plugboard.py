import pytest
from starlette.testclient import TestClient
from server.lib.routes import plugboard  

# Instantiate the test client
client = TestClient(plugboard)

# Test cases for plugboard configuration
@pytest.mark.asyncio
async def test_configure_plugboard():
    # Test successful plugboard configuration
    response = await client.post(
        "/plugboard/save",
        json={"plug": {"plug_a": "a", "plug_b": "b"}, "machine": 1, "username": "test_user"}
    )
    assert response.status_code == 200

@pytest.mark.asyncio
async def test_configure_plugboard_invalid_input():
    # Test plugboard configuration with invalid input
    response = await client.post(
        "/plugboard/save",
        json={"plug": {"plug_a": "a", "plug_b": "b", "plug_c": "c"}, "machine": 1, "username": "test_user"}
    )
    assert response.status_code == 400
    

# Test case for retrieving plugboard configuration
@pytest.mark.asyncio
async def test_get_plugboard_configuration():
    # Test retrieving plugboard configuration
    response = await client.get("/plugboard/1")
    assert response.status_code == 200


# Test case for updating plugboard configuration
@pytest.mark.asyncio
async def test_update_plugboard_configuration():
    # Test updating plugboard configuration
    response = await client.put(
        "/plugboard/update",
        json={"plug": {"plug_a": "b", "plug_b": "a"}, "machine": 1, "username": "test_user"}
    )
    assert response.status_code == 200

# Test case for deleting plugboard configuration
@pytest.mark.asyncio
async def test_delete_plugboard_configuration():
    # Test deleting plugboard configuration
    response = await client.delete("/plugboard/delete/1")
    assert response.status_code == 200
