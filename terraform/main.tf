# Enable required APIs
resource "google_project_service" "apis" {
  for_each = toset([
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com"
  ])

  service            = each.key
  disable_on_destroy = false
  project            = var.project_id
}

# Create Artifact Registry repository
resource "google_artifact_registry_repository" "docker_repo" {
  location      = var.region
  repository_id = "${var.service_name}-repo"
  description   = "Docker repository for ${var.service_name}"
  format        = "DOCKER"

  depends_on = [google_project_service.apis]
}

# Create service account for Cloud Run
resource "google_service_account" "cloud_run_sa" {
  account_id   = "${var.service_name}-sa"
  display_name = "Service Account for ${var.service_name} Cloud Run"
  project      = var.project_id

  depends_on = [google_project_service.apis]
}

# Grant minimal permissions
resource "google_project_iam_member" "cloud_run_invoker" {
  project = var.project_id
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}

resource "google_project_iam_member" "logging_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}

resource "google_project_iam_member" "monitoring_metric_writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}

# Create Cloud Run service (private by default)
resource "google_cloud_run_service" "insight_agent" {
  name     = var.service_name
  location = var.region
  project  = var.project_id

  template {
    spec {
      service_account_name = google_service_account.cloud_run_sa.email
      
      containers {
        image = "${google_artifact_registry_repository.docker_repo.location}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker_repo.repository_id}/insight-agent:${var.image_tag}"
        
        ports {
          container_port = 8080
        }
        
        resources {
          limits = {
            cpu    = "1000m"
            memory = "512Mi"
          }
        }
        
        env {
          name  = "ENVIRONMENT"
          value = var.environment
        }
        
        startup_probe {
          http_get {
            path = "/health"
            port = 8080
          }
          initial_delay_seconds = 5
          timeout_seconds       = 3
          period_seconds        = 10
          failure_threshold     = 3
        }
      }
    }
    
    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale" = "10"
        "autoscaling.knative.dev/minScale" = "1"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [
    google_project_service.apis,
    google_artifact_registry_repository.docker_repo,
    google_service_account.cloud_run_sa
  ]
}

# Make Cloud Run service private (no unauthorized access)
resource "google_cloud_run_service_iam_member" "noauth" {
  location = google_cloud_run_service.insight_agent.location
  project  = google_cloud_run_service.insight_agent.project
  service  = google_cloud_run_service.insight_agent.name
  role     = "roles/run.invoker"
  member   = "allUsers"
  count    = 0 # Disable public access - set to 1 to enable specific users
  
  # In production, use specific members:
  # member = "serviceAccount:some-service-account@project.iam.gserviceaccount.com"
}

# Optional: Create Cloud Armor security policy if allowing specific IPs
resource "google_compute_security_policy" "cloud_armor_policy" {
  count = length(var.allowed_ips) > 0 ? 1 : 0
  
  name    = "${var.service_name}-security-policy"
  project = var.project_id

  rule {
    action   = "allow"
    priority = "1000"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = var.allowed_ips
      }
    }
    description = "Allow specific IP addresses"
  }

  rule {
    action   = "deny(403)"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "Default deny all"
  }
}

# Setup Cloud Monitoring alert policies
resource "google_monitoring_alert_policy" "high_error_rate" {
  display_name = "High Error Rate - ${var.service_name}"
  combiner     = "OR"
  conditions {
    display_name = "High HTTP error rate"
    condition_threshold {
      filter     = "metric.type=\"run.googleapis.com/request_count\" resource.type=\"cloud_run_revision\" metric.label.response_code_class!=\"2xx\""
      comparison = "COMPARISON_GT"
      threshold_value = 10
      duration   = "60s"
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }

  notification_channels = [] # Add notification channel IDs here

  depends_on = [google_cloud_run_service.insight_agent]
}

resource "google_monitoring_alert_policy" "high_latency" {
  display_name = "High Latency - ${var.service_name}"
  combiner     = "OR"
  conditions {
    display_name = "High request latency"
    condition_threshold {
      filter     = "metric.type=\"run.googleapis.com/request_latencies\" resource.type=\"cloud_run_revision\""
      comparison = "COMPARISON_GT"
      threshold_value = 1000 # milliseconds
      duration   = "300s"
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_PERCENTILE_99"
      }
    }
  }

  notification_channels = [] # Add notification channel IDs here

  depends_on = [google_cloud_run_service.insight_agent]
}

# Create Cloud Scheduler for periodic health checks (optional)
resource "google_cloud_scheduler_job" "health_check" {
  name        = "${var.service_name}-health-check"
  description = "Periodic health check for ${var.service_name}"
  schedule    = "*/5 * * * *" # Every 5 minutes
  time_zone   = "UTC"

  http_target {
    uri         = "${google_cloud_run_service.insight_agent.status[0].url}/health"
    http_method = "GET"
    oidc_token {
      service_account_email = google_service_account.cloud_run_sa.email
    }
  }

  depends_on = [google_cloud_run_service.insight_agent]
}