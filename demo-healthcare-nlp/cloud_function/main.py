import base64
import json
import logging
import os
import google.auth

from google.auth.transport import requests
from google.oauth2 import service_account
from google.api_core import retry
from google.cloud import storage
from google.cloud import bigquery

JSON_HEADERS = {"Content-Type": "application/fhir+json;charset=utf-8"}
CREDENTIALS, PROJECT_ID = google.auth.default()
CS = storage.Client()
BQ = bigquery.Client()

def gcs_nlp_bigquery(event, context):
  # Process input bucket data through NLP API and store responses in coreesponding output bucket folder
  nlp_to_gcs()
  # Load each output bucket folder to bigquery table
  load_bigquery("entities")
  load_bigquery("entityMentions")
  load_bigquery("relationships")

# Load job to import output bucket folder data to bigquery table
def load_bigquery(report_type):
  table_id = "%s.%s.%s"%(PROJECT_ID,os.environ.get('DATASET', 'Dataset is not set.'),report_type)
  job_config = bigquery.LoadJobConfig(
    autodetect=True,
    source_format=bigquery.SourceFormat.NEWLINE_DELIMITED_JSON,
  )
  uri = "gs://%s/%s/*"%(os.environ.get('OUTPUT_BUCKET', 'GCS NLP Reports Bucket is not set.'),report_type)
  load_job = BQ.load_table_from_uri(
    uri,
    table_id,
    location="US", 
    job_config=job_config,
  )
  load_job.result()  # Waits for the job to complete.

# Process input bucket data through NLP API and store each report's response attribute (entities, entityMentions, relationships) in proper output bucket folder
def nlp_to_gcs():
  blobs = CS.list_blobs(os.environ.get('INPUT_BUCKET', 'Input bucket not specified.'))
  nlp_data = {}
  for blob in blobs:
    # Process report through NLP API
    medical_text = blob.download_as_string()
    nlp_request = {'documentContent': medical_text.decode('utf-8')}
    resource_path = "https://healthcare.googleapis.com/v1beta1/projects/%s/locations/us-central1/services/nlp:analyzeEntities"%(PROJECT_ID)
    session = requests.AuthorizedSession(CREDENTIALS)
    response = session.request('POST',resource_path, headers=JSON_HEADERS,data=json.dumps(nlp_request))
    response_data = json.loads(response.text)
    # Upload (attribute specific) nlp response to proper output bucket folder 
    upload_gcs(blob.name, response_data['entities'], "entities")
    upload_gcs(blob.name, response_data['entityMentions'], "entityMentions")
    upload_gcs(blob.name, response_data['relationships'], "relationships")

# Upload nlp response to specified gcs output bucket folder (report_type)
def upload_gcs(report_name, response, report_type):
    bucket = CS.bucket(os.environ.get('OUTPUT_BUCKET', 'GCS NLP Reports Bucket is not set.'))
    blob = bucket.blob("%s/%s"%(report_type,report_name))
    data = [json.dumps(record) for record in response]
    data_str = ','.join(data)
    upload_str = "{\"report\": \"%s\",\"%s\": [%s]}\n"%(report_name,report_type,data_str)
    blob.upload_from_string(upload_str,content_type="application/json")
