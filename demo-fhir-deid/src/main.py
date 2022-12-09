import base64
from parse import *
import requests
from googleapiclient import discovery

def fhirProcesser(event, context):
    """Triggered from a message on a Cloud Pub/Sub topic.
    Args:
         event (dict): Event payload.
         context (google.cloud.functions.Context): Metadata for the event.
    """

    pubsub_message = base64.b64decode(event['data']).decode('utf-8')
    # Extract the relevant portions from the Pub/Sub message.
    extract = parse("projects/{project}/locations/{location}/datasets/{datasetName}/fhirStores/{storeName}", pubsub_message)
    fhir_dict = extract.named

    project_id = fhir_dict["project"]
    location = fhir_dict["location"]
    dataset_name = fhir_dict["datasetName"]
    destination_dataset_id = 'my-deidentified-dataset'

    source_dataset = "projects/{}/locations/{}/datasets/{}".format(
        project_id, location, dataset_name
    )
    destination_dataset = "projects/{}/locations/{}/datasets/{}".format(
        project_id, location, destination_dataset_id
    )

    api_version = "v1"
    service_name = "healthcare"
    # Returns an authorized API client by discovering the Healthcare API
    # and using GOOGLE_APPLICATION_CREDENTIALS environment variable.
    client = discovery.build(service_name, api_version)

    deidentifyDataset(client, source_dataset, destination_dataset)

def deidentifyDataset(client, source_dataset, destination_dataset):
    # De-Identification of original FHIR dataset
    body = {
          "destinationDataset" : destination_dataset,
          "config" : {
               "fhir": {}
          }
     }

    request = (
        client.projects()
        .locations()
        .datasets()
        .deidentify(sourceDataset=source_dataset, body=body)
    )

    response = request.execute()
    print(
        "Data in dataset {} de-identified."
    )

def pollRequest(client, destination_dataset):
    parent = 'projects/lias-project/locations/us-central1'

    request = (
        client.projects()
        .locations()
        .datasets()
        .list(parent=parent)
    )
    while True:
        response = request.execute()
        if destination_dataset in response.get('datasets', []):
            break

def exportDataset(client, source_dataset, destination_bucket):
    # Export de-identified dataset to Cloud Storage bucket
    fhir_store_name = "{}/fhirStore/example-fhir-store"
    body = {"gcsDestination": {"uriPrefix": "gs://{}".format(destination_bucket)}}

    request = (
        client.projects()
        .locations()
        .datasets()
        .fhirStores()
        .export(name=fhir_store_name, body=body)
    )

    response = request.execute()
    print("Exported FHIR resources to bucket: gs://{}".format(destination_bucket))


 
