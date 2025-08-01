terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
     kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}
provider "google" {
  project = var.project
  region  = var.region
}

data "google_client_config" "provider" {
}

resource "google_project_service" "compute" {
  ## Needed to deploy Compute Engine services
  project            = var.project
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "container" {
  ## Needed to deploy Compute Engine services
  project            = var.project
  service            = "container.googleapis.com"
  disable_on_destroy = false
}