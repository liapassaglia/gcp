# Enable project APIs
resource "google_project_service" "iam-api" {
  project = var.project
  service = "iam.googleapis.com"
}

resource "google_project_service" "compute-api" {
  project = var.project
  service = "compute.googleapis.com"
}

resource "google_project_service" "resourcemanager-api" {
  project = var.project
  service = "cloudresourcemanager.googleapis.com"
}

resource "google_project_service" "containerregistry-api" {
  project = var.project
  service = "containerregistry.googleapis.com"
}

resource "google_project_service" "aiplatform-api" {
  project = var.project
  service = "aiplatform.googleapis.com"
}

resource "google_project_service" "cloudbuild-api" {
  project = var.project
  service = "cloudbuild.googleapis.com"
}

resource "google_project_service" "cloudfunctions-api" {
  project = var.project
  service = "cloudfunctions.googleapis.com"
}

# Create a custom default service account for Vertex AI Workbench
resource "google_service_account" "workbench-default" {
  account_id   = "workbench-default"
  display_name = "Default service account for AI workbench"
}

# Grant Workbench service account the Storage Object Admin role
resource "google_project_iam_binding" "workbench-default-custom-storage-reader" {
  project = var.project
  role    = "roles/storage.objectAdmin"
  members = ["serviceAccount:${google_service_account.workbench-default.email}"]
}

# Grant Workbench service account the Cloud Functions Developer role
resource "google_project_iam_binding" "workbench-default-functions-developer" {
  project = var.project
  role    = "roles/cloudfunctions.developer"
  members = ["serviceAccount:${google_service_account.workbench-default.email}"]
}

# Create a GCS Bucket to store pipeline spec file
resource "google_storage_bucket" "pipeline-bucket" {
  name     = "demo-mlops-vertexai-pipeline-bucket"
  location = "us-central1"
  uniform_bucket_level_access = true
}

# Create a custom network
resource "google_compute_network" "vpc_network" {
  name                    = "demo-mlops-vertexai-vpc"
  auto_create_subnetworks = false
  mtu                     = 1460
}

# Create a custom subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "demo-mlops-vertexai-subnet"
  ip_cidr_range = "10.128.0.0/20"
  region        = "us-central1"
  network       = google_compute_network.vpc_network.id
}

# Create a Workbench notebook instance
resource "google_notebooks_instance" "demo-mlops-vertexai-notebook" {
  name               = "demo-mlops-vertexai"
  project            = var.project
  location           = "us-central1-a"
  machine_type       = "n1-standard-1" 
  vm_image {
    project      = "deeplearning-platform-release"
    image_family = "common-cpu-notebooks"
  }
  metadata = {
    terraform = "true"
  }
  network = google_compute_network.vpc_network.id
  subnet = google_compute_subnetwork.subnet.id
  service_account = "${google_service_account.workbench-default.email}"
}
