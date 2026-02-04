
from main import app
from fastapi.testclient import TestClient

client = TestClient(app)

def test_root():
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    print(f"✓ Root endpoint: {data['message']}")
    assert data["message"] == "Insight-Agent API is running!"

def test_health():
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    print(f"✓ Health check: {data}")
    assert data["status"] == "healthy"

def test_analyze():
    headers = {"Authorization": "Bearer test-token"}
    data = {"text": "I love cloud engineering Pawa IT!"}
    response = client.post("/analyze", json=data, headers=headers)
    
    assert response.status_code == 200
    result = response.json()
    print(f"✓ Analyze result: {result}")
    
    # Fixed assertions
    assert result["word_count"] == 6
    assert result["character_count"] == 33
    # Check sentiment is positive (contains "love")
    assert result["sentiment_score"] > 0
    # Check all expected fields exist
    assert "original_text" in result
    assert "sentence_count" in result
    assert "language" in result

def test_analyze_no_auth():
    data = {"text": "Test text"}
    response = client.post("/analyze", json=data)
    print(f"✓ Analyze without auth - Status: {response.status_code}")
    assert response.status_code in [401, 403, 422]

# Additional tests to add
def test_analyze_negative_sentiment():
    headers = {"Authorization": "Bearer test-token"}
    data = {"text": "I hate this terrible awful service"}
    response = client.post("/analyze", json=data, headers=headers)
    
    assert response.status_code == 200
    result = response.json()
    print(f"✓ Negative sentiment: score={result['sentiment_score']}")
    assert result["sentiment_score"] < 0  # Should be negative
    assert result["word_count"] == 6


def test_sentiment_calculation():
    headers = {"Authorization": "Bearer test-token"}
    test_cases = [
        ("I love this", 1/3),  # 1 positive / 3 words
        ("I hate this", -1/3),  # 1 negative / 3 words
        ("Amazing awesome great", 3/3),  # 3 positive / 3 words
        ("Terrible awful bad", -3/3),  # 3 negative / 3 words
        ("Good but bad", 0/3),  # 1 positive, 1 negative = 0 / 3 words
    ]
    
    for text, expected_score in test_cases:
        response = client.post("/analyze", json={"text": text}, headers=headers)
        assert response.status_code == 200
        result = response.json()
        # Allow small floating point differences
        assert abs(result["sentiment_score"] - expected_score) < 0.01