# Replace {PROJECT_ID} and {GCP_REGION} with your project ID and desired region.

curl -X POST \
    -H "Authorization: Bearer $(gcloud auth print-access-token)" \
    -H "Content-Type: application/fhir+json" \
    -d @original.json \
    "https://healthcare.googleapis.com/v1/projects/lias-project/locations/us-central1/datasets/example-dataset/fhirStores/example-fhir-store/fhir/Patient"
