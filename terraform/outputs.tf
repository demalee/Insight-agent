output "cloud_run_url" {
  description = "Cloud Run service URL"
  value       = google_cloud_run_service.main.status[0].url
}

output "service_account_email" {
  description = "Service account email"
  value       = google_service_account.cloud_run_sa.email
}

output "artifact_registry_repo" {
  description = "Artifact Registry repository"
  value       = google_artifact_registry_repository.docker_repo.repository_id
}

output "vpc_connector" {
  description = "VPC Access Connector ID"
  value       = module.networking.connector_id
}

output "monitoring_dashboard" {
  description = "Monitoring dashboard URL"
  value       = "https://console.cloud.google.com/monitoring/dashboards?project=${var.project_id}"
}

output "logs_explorer" {
  description = "Logs Explorer URL"
  value       = "https://console.cloud.google.com/logs/query?project=${var.project_id}"
}

output "service_metrics" {
  description = "Service metrics URL"
  value       = "https://console.cloud.google.com/run/detail/${var.region}/${var.service_name}/metrics?project=${var.project_id}"
}