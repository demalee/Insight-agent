variable "project_id" {
  description = "Insight-agent-pawa-it"
  type        = string
  default     = "insight-agent-pawa-it"
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

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "image_tag" {
  description = "Docker image tag"
  type        = string
  default     = "latest"
}

variable "image_source" {
  description = "Source of Docker image (dockerhub or artifact-registry)"
  type        = string
  default     = "artifact-registry"
  validation {
    condition     = contains(["dockerhub", "artifact-registry"], var.image_source)
    error_message = "Image source must be dockerhub or artifact-registry."
  }
}

variable "devdemalee" {
  description = "devdemalee"
  type        = string
  default     = ""
}

variable "public_access" {
  description = "Allow public access to the service"
  type        = bool
  default     = true
}

variable "container_port" {
  description = "Container port"
  type        = number
  default     = 8080
}

variable "cpu_limit" {
  description = "CPU limit"
  type        = string
  default     = "1000m"
}

variable "memory_limit" {
  description = "Memory limit"
  type        = string
  default     = "512Mi"
}

variable "container_concurrency" {
  description = "Maximum number of concurrent requests per container"
  type        = number
  default     = 80
}

variable "timeout_seconds" {
  description = "Request timeout in seconds"
  type        = number
  default     = 300
}

variable "min_scale" {
  description = "Minimum number of container instances"
  type        = number
  default     = 0
}

variable "max_scale" {
  description = "Maximum number of container instances"
  type        = number
  default     = 10
}

variable "custom_domain" {
  description = "Custom domain for the service"
  type        = string
  default     = ""
}

variable "enable_secrets" {
  description = "Enable Secret Manager integration"
  type        = bool
  default     = false
}

variable "cloudsql_instance" {
  description = "Cloud SQL instance connection name"
  type        = string
  default     = ""
}

variable "image_tag" {
  description = "Docker image tag for deployment"
  type        = string
  default     = "latest"
}

variable "allowed_service_account" {
  description = "Service account allowed to invoke the private Cloud Run service"
  type        = string
  default     = ""  # Set to specific service account email
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}