terraform {
  backend "remote" {
    # The name of your Terraform Cloud organization.
    organization = "parfete"
    
    # The name of the Terraform Cloud workspace to store Terraform state files in.
    workspaces {
      name = "parfete"
    }
  }
  required_providers {
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 4.0"
    }
  }
}

provider "google-beta" {
  user_project_override = true
}

provider "google-beta" {
  alias = "no_user_project_override"
  user_project_override = false
}

# Enables required APIs.
resource "google_project_service" "default" {
  provider = google-beta.no_user_project_override
  project  = google_project.default.project_id
  for_each = toset([
    "cloudbilling.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "firebase.googleapis.com",
    # Enabling the ServiceUsage API allows the new project to be quota checked from now on.
    "serviceusage.googleapis.com",
  ])
  service = each.key

  # Don't disable the service if the resource block is removed by accident.
  disable_on_destroy = false
}

# Enables Firebase services for the new project created above.
resource "google_firebase_project" "default" {
  provider = google-beta
  project  = google_project.default.project_id

  # Waits for the required APIs to be enabled.
  depends_on = [
    google_project_service.default
  ]
}

# Creates a Firebase Android App in the new project created above.
resource "google_firebase_android_app" "default" {
  provider = google-beta

  project      = google_project.default.project_id
  display_name = "My Awesome Android app"
  package_name = "awesome.package.name"

  # Wait for Firebase to be enabled in the Google Cloud project before creating this App.
  depends_on = [
    google_firebase_project.default,
  ]
}



