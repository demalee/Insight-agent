output "cloud_run_url" {
  description = "Cloud Run service URL (internal only)"
  value       = google_cloud_run_service.main.status[0].url
}

output "cloud_run_service_name" {
  description = "Cloud Run service name"
  value       = google_cloud_run_service.main.name
}

output "service_account_email" {
  description = "Service account email for Cloud Run"
  value       = google_service_account.cloud_run_sa.email
}

output "artifact_registry_repo" {
  description = "Artifact Registry repository name"
  value       = google_artifact_registry_repository.docker_repo.repository_id
}

output "artifact_registry_url" {
  description = "Artifact Registry repository URL"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker_repo.repository_id}"
}

output "cloud_run_region" {
  description = "Cloud Run service region"
  value       = var.region
}

output "logs_explorer" {
  description = "Cloud Logging Explorer URL"
  value       = "https://console.cloud.google.com/logs/query?project=${var.project_id}&resource=cloud_run_revision"
}

output "service_metrics" {
  description = "Service metrics URL"
  value       = "https://console.cloud.google.com/run/detail/${var.region}/${var.service_name}/metrics?project=${var.project_id}"
}

output "iam_policy_status" {
  description = "Cloud Run IAM policy status (no public access)"
  value       = "Cloud Run service is PRIVATE - only accessible to authenticated users"
}