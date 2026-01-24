# Insight-Agent: Cloud Text Analysis Service

A production-ready, serverless text analysis API deployed on Google Cloud Platform for Insight-agent Pawa IT Assignment.

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
# Navigate to app directory
cd app

# Run the application
python main.py
# or if using uvicorn for FastAPI:
uvicorn main:app --reload --port 8080 - unaweza change to different port


# Build the Docker image
docker build -t text-analyzer:latest ./app

# Run the container
docker run -p 8080:8080 text-analyzer:latest

# Test the running container
curl -X POST http://localhost:8080/analyze \
  -d '{"text": "Testing Docker container"}'

  For GCP Set up and auth , follow this :

  # Authenticate with GCP
gcloud auth login
gcloud auth application-default login

# Set your GCP project
gcloud config set project insight-agent-pawa-it

# Enable required APIs
gcloud services enable \
  cloudbuild.googleapis.com \
  run.googleapis.com \
  artifactregistry.googleapis.com \
  iam.googleapis.com

for terrafrom :

# Navigate to terraform directory
cd terraform

# Initialize Terraform (downloads providers)
terraform init

# Review what will be created
terraform plan

# Apply the configuration
terraform apply

# View outputs (contains Cloud Run URL, etc.)
terraform output

terraform validate
terraform plan -var="project_id=insight-agent-pawa-it" -var="image_tag=latest"

#HAppy path - Manual Deployment to Cloud Run

# Build and push to Artifact Registry
gcloud builds submit --tag us-central1-docker.pkg.dev/insight-agent-pawa-it/insight-agent-repo/app:latest
 #ama just 
 gcloud builds submit .
# Deploy to Cloud Run
gcloud run deploy text-analyzer \
  --image us-central1-docker.pkg.dev/PROJECT/REPO/app:latest \
  --platform managed \
  --region us-central1 \
  --no-allow-unauthenticated


sampe output :

{
  "original_text": "This is a wonderful test",
  "word_count": 5,
  "character_count": 24,
  "sentence_count": 1,
  "sentiment_score": 0.0,
  "language": "en"
}

# Cloud Build CI/CD enabled
project-root/
├── app/
│   ├── main.py              # FastAPI/Flask application
│   ├── requirements.txt     # Python dependencies
│   └── Dockerfile          # Container configuration
├── terraform/
│   ├── main.tf            # Main Terraform configuration-ya kuset CPU ,Memory ect (for infrastructure)
│   ├── variables.tf       # Variable definitions
│   ├── outputs.tf         # Output values
│   └── .terraform-version # Terraform version
├── .github/
│   └── workflows/
│       └── deploy.yml     # GitHub Actions pipeline
├── .gitignore
└── README.md