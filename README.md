# Insight-Agent: Cloud Text Analysis Service

A production-ready, serverless text analysis API deployed on Google Cloud Platform.

## Architecture Overview


## Design Decisions

 1. Why Cloud Run
- Serverless: Automatic scaling
Cost-effective- Pay only for request processing time
Fast deployment- Container-based, easy updates
Integrated with GCP ecosystem- Native logging, monitoring, and IAM

 2.Security Implementation
- Private by default: Cloud Run service configured for internal access only
-Least privilege- Dedicated service account with minimal permissions
No public internet access- Requires authentication for all requests
Secure secrets-Managed through GitHub Secrets and GCP IAM

###CI/CD Pipeline
- GitHub Actions Platform-agnostic, integrates with GitHub
- Multi-stage- Test → Build → Deploy workflow
-Infrastructure as Code: Terraform manages all GCP resources
- Immutable deployments: Each commit generates unique Docker tag

### Logging & Monitoring
- Cloud Logging- Structured JSON logs with severity levels
-Cloud Monitoring- Custom metrics and alerting policies
-Health checks Startup and liveness probes
-Performance metrics Latency, error rates, request counts

## Setup & Deployment Instructions

### Prerequisites
1. GCP Account with billing enabled
2. GitHub Accountfor repository
3. Local Tools
   - Git
   - Python 3.11+
   - Docker
   - Terraform 1.5+
   - Google Cloud SDK

### Step 1: Clone Repository
```bash
git clone https://github.com/demalee/insight-agent.git
cd insight-agent

sampe output :

{
  "original_text": "This is a wonderful test",
  "word_count": 5,
  "character_count": 24,
  "sentence_count": 1,
  "sentiment_score": 0.0,
  "language": "en"
}# Cloud Build CI/CD enabled
