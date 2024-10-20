import boto3
import time

athena_client = boto3.client('athena')
s3_client = boto3.client('s3')

def lambda_handler(event, context):
    path = event['path']
    
    query = ""
    if path == "/customers":
        query = "SELECT client_id, client_name, total_sales, total_spending, most_sold_product FROM output_final_sales_report"
    elif path == "/products":
        query = "SELECT product_id, product_description, COUNT(*) AS total_sold FROM output_final_sales_report GROUP BY product_id, product_description ORDER BY total_sold DESC"
    elif path == "/orders":
        query = "SELECT order_id, client_name, product_description, product_price, status FROM output_final_sales_report"
    else:
        return {
            'statusCode': 400,
            'body': 'Endpoint no válido.'
        }

    response = athena_client.start_query_execution(
        QueryString=query,
        QueryExecutionContext={'Database': 'tech_challenge_database'},
        ResultConfiguration={
            'OutputLocation': 's3://my-output-bucket-tech-chall/athena-results/'
        }
    )
    
    query_execution_id = response['QueryExecutionId']
    
    query_state = None
    while query_state != 'SUCCEEDED':
        query_status = athena_client.get_query_execution(QueryExecutionId=query_execution_id)
        query_state = query_status['QueryExecution']['Status']['State']
        if query_state == 'FAILED':
            return {
                'statusCode': 500,
                'body': 'Error en la consulta de Athena'
            }
        elif query_state == 'CANCELLED':
            return {
                'statusCode': 500,
                'body': 'Consulta de Athena cancelada'
            }
        time.sleep(2) 

    s3_response = s3_client.get_object(Bucket='my-output-bucket-tech-chall', Key=f'athena-results/{query_execution_id}.csv')
    result_data = s3_response['Body'].read().decode('utf-8')
    
    return {
        'statusCode': 200,
        'body': result_data
    }
