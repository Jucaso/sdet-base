resource "aws_s3_bucket" "input_bucket" {
  bucket = "my-input-bucket-tech-chall"
}

resource "aws_s3_bucket" "output_bucket" {
  bucket = "my-output-bucket-tech-chall"
}

resource "aws_s3_bucket_notification" "input_bucket_notification" {
  bucket = aws_s3_bucket.input_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.trigger_glue_job.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".csv"
  }
}

resource "aws_s3_object" "lambda_api_script_zip" {
  bucket = aws_s3_bucket.output_bucket.id 
  key    = "lambda_functions/lambda_api_script.zip"
  source = "../Files_for_IaC/lambda_api_script.zip"
}

resource "aws_s3_object" "lambda_exe_script_zip" {
  bucket = aws_s3_bucket.output_bucket.id
  key    = "lambda_functions/lambda_exe_script.zip"
  source = "../Files_for_IaC/lambda_exe_script.zip"
}

resource "aws_s3_object" "glue_job_script" {
  bucket = aws_s3_bucket.input_bucket.id
  key    = "script/script.py"
  source = "../Files_for_IaC/script.py"
}
