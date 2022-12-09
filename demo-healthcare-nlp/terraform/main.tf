# input bucket
resource "google_storage_bucket" "nlp-input-bucket" {
	name = "nlp-input-bucket"
	location = "us-central1"
	force_destroy = true
	uniform_bucket_level_access = true
}

#output bucket
resource "google_storage_bucket" "nlp-output-bucket" {
	name = "nlp-output-bucket"
	location = "us-central1"
	force_destroy = true
	uniform_bucket_level_access = true
}

# bigquery dataset
resource "google_bigquery_dataset" "nlp-dataset" {
	dataset_id = var.dataset_id
	friendly_name = "nlp-dataset"
	location = "us-central1"
}

