# 1. VARIABLE DECLARATIONS (The "Input Slots")
# These must exist here for the TF_VAR_ environment variables in GitHub to work.

terraform {
  backend "gcs" {
    bucket = " jay-tf-state-12345" # Use the name you just created
    prefix = "terraform/state"
  }
}

variable "project_id" {
  description = "The Google Cloud Project ID"
  type        = string
}

variable "webhook_secret" {
  description = "The secret key for GitHub webhooks"
  type        = string
  sensitive   = true # Hides the value from being printed in GitHub Action logs
}

# 2. PROVIDER CONFIGURATION
provider "google" {
  project = var.project_id
  region  = "us-central1"
}

# 3. ENABLE APIs
# This ensures the necessary Google services are turned on.
resource "google_project_service" "run_api" {
  service            = "run.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "artifact_registry_api" {
  service            = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

# 4. ARTIFACT REGISTRY (The "Warehouse")
# This creates the room where your Docker images will live.
resource "google_artifact_registry_repository" "my_repo" {
  depends_on    = [google_project_service.artifact_registry_api]
  location      = "us-central1"
  repository_id = "my-repo"
  description   = "Docker repository for hello-app"
  format        = "DOCKER"
}

# 5. CLOUD RUN SERVICE
# This is the "House" for your code.
resource "google_cloud_run_v2_service" "default" {
  name     = "hello-world-service"
  location = "us-central1"
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    containers {
      # Note: On the first ever run, this image might not exist yet. 
      # Terraform will create the service, and your GitHub Action will 
      # immediately update it with the real image in the next step.
      image = "us-docker.pkg.dev/cloudrun/container/hello" 
      
      ports {
        container_port = 8080
      }

      env {
        name  = "WEBHOOK_SECRET"
        value = var.webhook_secret
      }
    }
  }

  depends_on = [google_project_service.run_api]
}

# 6. PUBLIC ACCESS (IAM)
# This allows GitHub (or anyone) to send a POST request to your webhook URL.
resource "google_cloud_run_v2_service_iam_member" "public_access" {
  name     = google_cloud_run_v2_service.default.name
  location = google_cloud_run_v2_service.default.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# 7. OUTPUTS
# This will print the URL of your app in the GitHub Action logs once finished.
output "service_url" {
  value = google_cloud_run_v2_service.default.uri
}