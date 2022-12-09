# Google Cloud - Healthcare NLP API
This repository serves as an example on how to use Google's Healthcare NLP API to extract information (entities, entityMentions, and relationships) from plain text documents. 

Objective
The system will process plain text files from a GCS input bucket through the Healthcare NLP API before placing output attributes (entites, entityMentions, and relationships) in 3 distinct BigQuery tables. 

The process is as follows:

Upload plain text file to input bucket.
Cloud Function is triggered by the previous notification.
The NLP API process is kicked off by the function.
Finally, the output of the API call is stored in GCS output bucket and in 3 distinct BigQuery tables. 

Terraform Resources
Terraform can be used to create input and output buckets and the BigQuery table.

Instructions
Prerequisites

Make sure you have replaced {PROJECT_ID}, {GCP_REGION} with the relevant details for your case.
Make sure you have gcloud installed to be able to authenticate with GCP.
Usage

Start within the terraform/ directory (if you'd like to automate the creation of resources):

terraform plan to plan out resource creations.
terraform apply to create resources.
terraform destroy to destroy resources once you're finished with this example.
Note: The only resource that will not be deleted will be the de-identified dataset as that one was created via API. Make sure to manually delete it at the end.

Create Cloud Function:
Follow this guide to create a cloud function (either using GCP console or Cloud Shell)
https://cloud.google.com/functions/docs/tutorials/storage
Trigger: {GCS input bucket}
Environment variables: 
* input bucket = {GCS input bucket}
* output bucket = {GCS output bucket}
* dataset = {GCS dataset}
Source files can be found in cloud_function folder (main.py and requirements.txt)
