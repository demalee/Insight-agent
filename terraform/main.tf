terraform {
  required_version = ">= 1.0.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Enable APIs
resource "google_project_service" "apis" {
  for_each = toset([
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "iam.googleapis.com",
    "compute.googleapis.com"
  ])
  service = each.key
}

# VPC Network for private access
resource "google_compute_network" "vpc" {
  name                    = "insight-agent-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "insight-agent-subnet"
  region        = var.region
  network       = google_compute_network.vpc.id
  ip_cidr_range = "10.0.0.0/28"
}

# VPC Access Connector
resource "google_vpc_access_connector" "connector" {
  name          = "insight-agent-connector"
  region        = var.region
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.8.0.0/28"
}

# Artifact Registry Repository
resource "google_artifact_registry_repository" "docker_repo" {
  location      = var.region
  repository_id = "${var.service_name}-repo"
  description   = "Docker repository for ${var.service_name}"
  format        = "DOCKER"
  depends_on    = [google_project_service.apis["artifactregistry.googleapis.com"]]
}

# Service Account with least-privilege
resource "google_service_account" "cloud_run_sa" {
  account_id   = "${var.service_name}-sa"
  display_name = "Service Account for ${var.service_name}"
  description  = "Least-privilege service account for Cloud Run"
}

# Grant Cloud Run service minimal permissions
resource "google_project_iam_member" "cloud_run_logs" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}

resource "google_project_iam_member" "cloud_run_metrics" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}

# Cloud Run Service (PRIVATE - NOT publicly accessible)
resource "google_cloud_run_service" "main" {
  name     = var.service_name
  location = var.region

  template {
    spec {
      service_account_name = google_service_account.cloud_run_sa.email

      containers {
        image = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker_repo.repository_id}/${var.service_name}:${var.image_tag}"

        ports {
          container_port = var.container_port
        }

        env {
          name  = "PORT"
          value = var.container_port
        }

        env {
          name  = "K_SERVICE"
          value = var.service_name
        }

        resources {
          limits = {
            cpu    = var.cpu_limit
            memory = var.memory_limit
          }
        }
      }

      timeout_seconds       = var.timeout_seconds
      container_concurrency = var.container_concurrency
    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/minScale"        = var.min_scale
        "autoscaling.knative.dev/maxScale"        = var.max_scale
        "run.googleapis.com/vpc-access-connector" = google_vpc_access_connector.connector.id
        "run.googleapis.com/egress"               = "all-traffic"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [
    google_project_service.apis["run.googleapis.com"],
    google_artifact_registry_repository.docker_repo,
    google_vpc_access_connector.connector
  ]
}

# SECURITY: Block public access - Cloud Run service is PRIVATE ONLY
resource "google_cloud_run_service_iam_policy" "no_public_access" {
  service  = google_cloud_run_service.main.name
  location = google_cloud_run_service.main.location

  policy_data = data.google_iam_policy.no_public_access.policy_data
}

data "google_iam_policy" "no_public_access" {
  binding {
    role = "roles/run.invoker"
    members = [
      "serviceAccount:${google_service_account.cloud_run_sa.email}",
      # Add other specific service accounts if needed, but NOT "allUsers"
    ]
  }
}