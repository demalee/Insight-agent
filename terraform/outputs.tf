output "cloud_run_url" {
  description = "URL of the deployed Cloud Run service"
  value       = google_cloud_run_service.insight_agent.status[0].url
}

output "artifact_registry_repository" {
  description = "Artifact Registry repository details"
  value       = google_artifact_registry_repository.docker_repo.repository_id
}

output "service_account_email" {
  description = "Cloud Run service account email"
  value       = google_service_account.cloud_run_sa.email
}

output "project_id" {
  description = "GCP Project ID"
  value       = var.insight-agent-pawa-it
}

output "region" {
  description = "GCP Region"
  value       = var.region
}