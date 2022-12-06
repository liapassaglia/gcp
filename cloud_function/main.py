
import os
from google.cloud import aiplatform

def trigger_pipeline(event, context):
  if 'annotations.csv' in event['name']:
    project = os.getenv("PROJECT")
    region = os.getenv("REGION")
    gcs_pipeline_file_location = os.getenv("GCS_PIPELINE_FILE_LOCATION")
    dataset_name = os.getenv("DATASET_NAME")
    model_name = os.getenv("MODEL_NAME")

    bucket = event["bucket"]
    filepath = event['name']

    print('before init')
    aiplatform.init(project=project, location=region)    
    print('after init')

    print('before job')
    print(f'gs://{bucket}/{filepath}')
    job = aiplatform.PipelineJob(
        display_name='automl-cifar10-pipeline',
        template_path=f'gs://{gcs_pipeline_file_location}',
        pipeline_root=f'gs://vertexai-demo-pipeline',
        parameter_values={
            'project_id': project,
            'location': region,
            'dataset_name': dataset_name,
            'dataset_path': f'gs://{bucket}/{filepath}',
            'base_model_name': model_name,
        }
    )
    print('after job')

    job.submit()
