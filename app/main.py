

import os
import logging
from typing import Dict, Any
from fastapi import FastAPI, HTTPException, Security, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
import google.cloud.logging

# Configure logging
if os.environ.get("K_SERVICE"):  # Running on GCP
    client = google.cloud.logging.Client()
    client.setup_logging()
else:
    logging.basicConfig(level=logging.INFO)

logger = logging.getLogger(__name__)

# Security
security = HTTPBearer()

# Data Models
class TextAnalysisRequest(BaseModel):
    text: str = Field(..., min_length=1, max_length=5000, 
                     description="Text to analyze (max 5000 characters)")

class TextAnalysisResponse(BaseModel):
    original_text: str
    word_count: int
    character_count: int
    sentence_count: int = None
    sentiment_score: float = None
    language: str = "en"

# Initialize FastAPI
app = FastAPI(
    title="Insight-Agent API",
    description="AI-powered text analysis service for customer feedback",
    version="1.0.0"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

def verify_token(credentials: HTTPAuthorizationCredentials = Security(security)):
    """Verify API token (simplified - implement proper auth in production)"""
    # In production, validate against GCP IAM or external auth service
    token = credentials.credentials
    if not token:
        raise HTTPException(status_code=403, detail="Invalid credentials")
    return token

def analyze_text(text: str) -> Dict[str, Any]:
    """Perform text analysis"""
    # Basic analysis
    word_count = len(text.split())
    character_count = len(text)
    
    # Simple sentence detection
    sentences = [s.strip() for s in text.replace('!', '.').replace('?', '.').split('.') if s.strip()]
    sentence_count = len(sentences) if sentences else 1
    
    # Simple sentiment analysis (placeholder - integrate ML model in production)
    positive_words = ["love", "furaha", "excellent", "good", "happy", "awesome"]
    negative_words = ["hate", "bad", "terrible", "awful", "poor"]
    
    words = text.lower().split()
    positive_score = sum(1 for word in words if word in positive_words)
    negative_score = sum(1 for word in words if word in negative_words)
    sentiment_score = (positive_score - negative_score) / max(len(words), 1)
    
    return {
        "word_count": word_count,
        "character_count": character_count,
        "sentence_count": sentence_count,
        "sentiment_score": round(sentiment_score, 2)
    }

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy", "service": "insight-agent"}

@app.post("/analyze", response_model=TextAnalysisResponse)
async def analyze_text_endpoint(
    request: TextAnalysisRequest,
    token: str = Depends(verify_token)
):
  
    try:
        logger.info(f"Analyzing text: {request.text[:100]}...")
        
        analysis = analyze_text(request.text)
        
        response = TextAnalysisResponse(
            original_text=request.text,
            **analysis
        )
        
        logger.info(f"Analysis completed: {analysis}")
        return response
        
    except Exception as e:
        logger.error(f"Error analyzing text: {str(e)}")
        raise HTTPException(status_code=500, detail="Internal server error")

if __name__ == "__main__":
    import uvicorn
    port = int(os.environ.get("PORT", 8080))
    uvicorn.run(app, host="0.0.0.0", port=port)