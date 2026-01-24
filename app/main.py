

import os
import logging
from typing import Dict, Any
from fastapi import FastAPI, HTTPException, Security, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
import google.cloud.logging

# Configure logging
 
if os.environ.get("K_SERVICE"):  # Running on GCP (Google Cloud Platform)
    # When running on Google Cloud (like Cloud Run), use Google's logging service
    client = google.cloud.logging.Client()
    client.setup_logging()
else:
    logging.basicConfig(level=logging.INFO)    # When running locally, use basic console logging

logger = logging.getLogger(__name__)

# Security

security = HTTPBearer()# an "Authorization: Bearer <token>" header with their requests

# Data Models
#These classes define the expected structure of data coming in and going out
class TextAnalysisRequest(BaseModel):
     # This is the #input form# for the /analyze endpoint
    text: str = Field(..., min_length=1, max_length=5000, 
                     description="Text to analyze (max 5000 characters)")

class TextAnalysisResponse(BaseModel):
    # This is the "output form" - what the API returns after analysis
    original_text: str # The text that was sent to us
    word_count: int # Number of words in the text
    character_count: int # Number of characters (including spaces)
    sentence_count: int = None  # Optional field (might not be calculated)
    sentiment_score: float = None
    language: str = "en"  # Default to English, can be detected

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
    #  Basic analysis
    word_count = len(text.split())
    character_count = len(text)
    
    # Simple sentence detection
    sentences = [s.strip() for s in text.replace('!', '.').replace('?', '.').split('.') if s.strip()]
    sentence_count = len(sentences) if sentences else 1
    
    positive_words = ["amazinf", "cool stuff", "excellent", "good", "happy", "awesome"]
    negative_words = ["hate", "bad", "terrible", "awful", "poor"]
  
    words = text.lower().split()  # Convert text to lowercase for case-insensitive comparison
    positive_score = sum(1 for word in words if word in positive_words) # Count how many positive words appear
    negative_score = sum(1 for word in words if word in negative_words)  # Count how many negative words appear 
    sentiment_score = (positive_score - negative_score) / max(len(words), 1)
   
    return {
        "word_count": word_count,
        "character_count": character_count,
        "sentence_count": sentence_count,
        "sentiment_score": round(sentiment_score, 2)
    }

@app.get("/health") #Monitoring systems call this to see if the API is alive and working.
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
    port = int(os.environ.get("PORT", 8000))
    uvicorn.run(app, host="0.0.0.0", port=port)
   
@app.get("/")
async def root():
    """Root endpoint with API information for testing"""
    return {
        "message": "Insight-Agent API is running!",
        "status": "healthy",
        "version": "1.0.0",
        "try_these": {
            "health_check": "http://127.0.0.1:8000/health",
            "documentation": "http://127.0.0.1:8000/docs",
            "analyze_endpoint": "POST http://127.0.0.1:8000/analyze"
        }
    }
#testing something