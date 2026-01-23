# Insight-Agent Codebase Instructions

## Project Overview
Insight-Agent is a FastAPI-based text analysis microservice (PAWAIT Solutions) that provides sentiment analysis, word count, and character count capabilities via REST API. The service includes security (Bearer token authentication), structured logging with Google Cloud, and infrastructure-as-code via Terraform.

## Architecture & Key Components

### Core Service (app/main.py)
- **Framework**: FastAPI 0.104.1 with Uvicorn ASGI server
- **Port**: 8080 (configurable via environment)
- **Key Functions**:
  - `analyze_sentiment()` - Counts positive/negative keyword occurrences to determine sentiment
  - `/analyze` endpoint - Main POST endpoint requiring Bearer token authentication
  - `/health` endpoint - Service health check
  - `/` - API metadata and endpoint documentation

### Authentication Pattern
Uses FastAPI's built-in `HTTPBearer` security scheme. All protected endpoints require Bearer token in Authorization header. **Note**: The current implementation has incomplete security integration (see Issues section).

### Logging Architecture
- Uses Python's standard `logging` module (level: INFO)
- Google Cloud Logging integration available via `google-cloud-logging` package
- All significant operations logged (analysis start/completion, errors)

## Development Workflow

### Environment Setup
```bash
# Install dependencies
cd app
pip install -r requirements.txt

# Run locally (development)
python main.py  # Starts uvicorn on 0.0.0.0:8080

# Or run directly with uvicorn
uvicorn main:app --host 0.0.0.0 --port 8080 --reload
```

### Testing
- **Framework**: pytest with pytest-asyncio for async endpoint testing
- **HTTP Client**: httpx for testing FastAPI endpoints
- **Location**: `app/tests/` (currently empty - tests needed)
- **Pattern**: Use pytest fixtures and `TestClient` from `fastapi.testclient` for endpoint testing

### Code Patterns to Follow
1. **Models**: Use Pydantic `BaseModel` for request/response validation (e.g., `TextRequest`, `TextResponse`)
2. **Async**: All route handlers use `async def` - maintain this pattern
3. **Error Handling**: Return HTTP exceptions with status codes and descriptive detail messages
4. **Logging**: Always log at operation boundaries (entry, completion, errors)



## Infrastructure
- **Terraform**: `terraform/` folder reserved for IaC (empty - under development)
- **.github/workflows**: CI/CD pipeline location (empty - under development)
- **Google Cloud**: Logging integration configured but not active

## Dependencies & Versions
- **fastapi** 0.104.1: Web framework
- **uvicorn** 0.24.0: ASGI server
- **pydantic** 2.5.0: Data validation
- **google-cloud-logging** 3.8.0: Cloud logging
- **pytest** 7.4.3: Testing framework
- **httpx** 0.25.1: HTTP client for testing
- **python-multipart** 0.0.6: Form data parsing

## When Adding Features
1. Always add Pydantic models for new request/response types
2. Create corresponding test cases in `app/tests/`
3. Log entry/exit points with context (user input relevance, not secrets)
4. Use async patterns for I/O operations
5. Update requirements.txt immediately with pip-freeze if adding dependencies
