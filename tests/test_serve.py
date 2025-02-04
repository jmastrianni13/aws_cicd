import pytest
import sanic
import sanic_testing
import pprint

from src.serve import app

@pytest.fixture
def test_client():
    return sanic_testing.testing.SanicTestClient(app)

def test_index_route(test_client):
    _, response = test_client.get('/')
    assert response.status == 200
    return

