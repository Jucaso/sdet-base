import boto3
import os

glue_client = boto3.client('glue')

def lambda_handler(event, context):
    glue_job_name = os.environ['GLUE_JOB_NAME']
    
    bucket_name = event['Records'][0]['s3']['bucket']['name']
    file_name = event['Records'][0]['s3']['object']['key']
    
    print(f"Archivo subido: {file_name} en el bucket {bucket_name}")

    response = glue_client.start_job_run(JobName=glue_job_name)

    return {
        'statusCode': 200,
        'body': f'Job de Glue iniciado con éxito. JobRunID: {response["JobRunId"]}'
    }
