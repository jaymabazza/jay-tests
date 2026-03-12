provider "google" {
  project = var.project_id
  region  = "us-central1"
}

# 1. Enable Required APIs
resource "google_project_service" "run_api" {
  service = "run.googleapis.com"
}

# This creates the "my-repo" warehouse
resource "google_artifact_registry_repository" "my-repo" {
  location      = "us-central1"
  repository_id = "my-repo"
  format        = "DOCKER"
}

# 2. Define the Cloud Run Service
resource "google_cloud_run_v2_service" "default" {
  name     = "hello-world-service"
  location = "us-central1"

  template {
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello" # Placeholder
      ports { container_port = 8080 }
    }
  }
}

# 3. Allow Public (Unauthenticated) Access
resource "google_cloud_run_v2_service_iam_member" "public" {
  name     = google_cloud_run_v2_service.default.name
  location = google_cloud_run_v2_service.default.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}