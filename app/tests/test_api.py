import pytest
from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_root():
    response = client.get("/")
    assert response.status_code == 200
    assert "message" in response.json()

def test_health():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "healthy"

def test_analyze():
    headers = {"Authorization": "Bearer test-token"}
    data = {"text": "I love cloud engineering!"}
    response = client.post("/analyze", json=data, headers=headers)
    
    assert response.status_code == 200
    data = response.json()
    assert data["word_count"] == 4
    assert data["character_count"] == 23
    assert data["sentiment"] == "positive"

def test_analyze_no_auth():
    data = {"text": "Test text"}
    response = client.post("/analyze", json=data)
    assert response.status_code == 403  # Unauthorized