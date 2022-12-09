variable region {}

resource "google_healthcare_dataset" "default" {
  name      = "example-dataset"
  location  = var.region
  time_zone = "America/Chicago"
}

resource "google_healthcare_fhir_store" "default" {
    name = "example-fhir-store"
    dataset = google_healthcare_dataset.default.id
    version = "R4"
    notification_config {
        pubsub_topic = google_pubsub_topic.topic.id
    }
}

resource "google_pubsub_topic" "topic" {
  name     = "fhir-notifications"
}

resource "google_storage_bucket" "healthcare_export" {
  name = "healthcare_export"
  force_destroy = true
  uniform_bucket_level_access = true
}
