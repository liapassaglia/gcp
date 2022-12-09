# Google Cloud - Healthcare Data Engine
This repository serves as an example on how to use Google's Healthcare Data Engine to run de-identification procedures on FHIR instances. 

## Objective
The system will de-identify FHIR instances that are uploaded to a FHIR datastore in the Healthcare Data Engine.

The process is as follows:
1. A FHIR instance is uploaded to the datastore.
2. The Healthcare Data Engine sends a notification to Pub/Sub about this change.
3. Cloud Function is triggered by the previous notification.
4. The de-identification process is kicked off by the function.
5. Finally, we are provided with a separate, de-identified dataset (copied from the original).

## Terraform Resources
Terraform is used to create a several resources:

1. A healthcare dataset.
2. A FHIR instance store together with a Pub/Sub Topic that sends change notifications.
3. A Cloud Function that is triggered by the above Pub/Sub messages, plus the function artifacts and storage buckets for it.
4. The necessary service accounts with roles to be able to invoke the Cloud Function and Healthcare API methods for the FHIR instances.

## FHIR Instances
FHIR instances are available online for free. The Healthcare Data Engine provides with API methods to work with HL7v2, FHIR, and DICOM. This repository is focused around the FHIR format, but can be extended to work with other types of healthcare data and other GCP resources.

# Instructions

**Prerequisites**

1. Make sure you have replaced `{PROJECT_ID}`, `{GCP_REGION}` with the relevant details for your case.
2. Make sure you have `gcloud` installed to be able to authenticate with GCP.

**Usage**

Start within the `terraform/` directory:

1. `terraform plan` to plan out resource creations.
2. `terraform apply` to create resources.
3. `terraform destroy` to destroy resources once you're finished with this example. 

**Note: The only resource that will not be deleted will be the de-identified dataset as that one was created via API. Make sure to manually delete it at the end.**

This will create all of the needed resources to process DICOM images.

Within `fhir/`:

1. Replace the project ID and GCP region to work with in the `upload.sh` script. 
2. Run `upload.sh`.

Within `export/`:

1. Replace the GCP region in `export_original.sh` and `export_final.sh`.
2. Use `export_original.sh` to get an export of the originally uploaded FHIR file.
3. Use `export_final.sh` to get an export of the de-identified FHIR file.
