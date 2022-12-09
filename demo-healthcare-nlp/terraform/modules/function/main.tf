variable "project" {}

# Create a storage bucket
resource "google_storage_bucket" "function_bucket" {
    name = "fhir-function"
    uniform_bucket_level_access = true
}

# Zip up the function's code for uploading
data "archive_file" "function_src" {
    type = "zip"
    source_dir  = "${path.root}/../src" # Directory where your Python source code is
    output_path = "${path.root}/../generated/src.zip"
}

# Upload the zipped files to the bucket
resource "google_storage_bucket_object" "zipped_func" {
    name   = "${data.archive_file.function_src.output_md5}.zip"
    bucket = google_storage_bucket.function_bucket.name
    source = "${path.root}/../generated/src.zip"
}

# Create the cloud function and specify the bucket and function objects within that bucket
resource "google_cloudfunctions_function" "fhirProcesser" {
    name = "fhirProcesser"
    description = "De-identification function for FHIR instances."
    available_memory_mb = 256
    source_archive_bucket = google_storage_bucket.function_bucket.name
    source_archive_object = google_storage_bucket_object.zipped_func.name
    timeout = 60
    runtime = "python38"
    ingress_settings = "ALLOW_INTERNAL_AND_GCLB"
    service_account_email = "${google_service_account.healthcare-sa.email}"
    entry_point = "fhirProcesser"
    event_trigger {
      event_type = "providers/cloud.pubsub/eventTypes/topic.publish"
      resource = "fhir-notifications"
    }
}

# We'll also create a new service account, and add the needed roles for calling the Clound Function and the Healthcare API
resource "google_service_account" "healthcare-sa" {
  account_id = "healthcare-sa"
  display_name = "Healthcare Service Account"
}

resource "google_project_iam_member" "storageAdmin" {
  project = var.project
  role = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.healthcare-sa.email}"
}

resource "google_project_iam_member" "pubsubEditor" {
  project = var.project
  role = "roles/pubsub.editor"
  member = "serviceAccount:${google_service_account.healthcare-sa.email}"
}

resource "google_project_iam_member" "functionsDeveloper" {
  project = var.project
  role = "roles/cloudfunctions.developer"
  member = "serviceAccount:${google_service_account.healthcare-sa.email}"
}

resource "google_project_iam_member" "datasetAdmin" {
  project = var.project
  role    = "roles/healthcare.datasetAdmin"
  member  = "serviceAccount:${google_service_account.healthcare-sa.email}"
}

resource "google_project_iam_member" "fhirStoreAdmin" {
  project = var.project
  role    = "roles/healthcare.fhirStoreAdmin"
  member  = "serviceAccount:${google_service_account.healthcare-sa.email}"
}

resource "google_project_iam_member" "fhirResourceEditor" {
  project = var.project
  role    = "roles/healthcare.fhirResourceEditor"
  member  = "serviceAccount:${google_service_account.healthcare-sa.email}"
}
