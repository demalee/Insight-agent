variable "project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "insight-agent-pawa-it" # Set via env var or terraform.tfvars
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}

variable "service_name" {
  description = "Cloud Run service name"
  type        = string
  default     = "insight-agent"
}

variable "image_tag" {
  description = "Docker image tag"
  type        = string
  default     = "latest"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "allowed_ips" {
  description = "List of IP addresses allowed to access the service"
  type        = list(string)
  default     = []
}

variable "service_account_email" {
  description = "Service account email for Cloud Run"
  type        = string
  default     = null
}