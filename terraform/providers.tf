terraform {
  required_version = ">= 1.0.0"
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.0"
    }
  }

  backend "gcs" {
    # Configured via environment variables or command line
    # bucket = "tf-state-bucket-name"
    # prefix = "insight-agent"
  }
}

provider "google" {
  project = var.insight-agent-pawa-it
  region  = var.region
}

provider "google-beta" {
  project = var.insight-agent-pawa-it
  region  = var.region
}