# This gcloud command will export the _de-identified_ DICOM instance as a JPEG to the healthcare_export bucket

curl -X POST \
    -H "Authorization: Bearer $(gcloud auth application-default print-access-token)" \
    -H "Content-Type: application/json; charset=utf-8" \
    --data "{
      'gcsDestination': {
        'uriPrefix': 'gs://healthcare_export/de-identified'
      },
    }" "https://healthcare.googleapis.com/v1/projects/lias-project/locations/us-central1/datasets/my-deidentified-dataset/fhirStores/example-fhir-store:export"
