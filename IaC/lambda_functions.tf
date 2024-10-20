resource "aws_iam_role" "lambda_role" {
  name = "lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "lambda_glue_policy" {
  name = "lambda-glue-permissions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "glue:StartJobRun"
        Effect = "Allow"
        Resource = aws_glue_job.etl_job.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_glue_policy.arn
}

resource "aws_lambda_function" "trigger_glue_job" {
  function_name = "trigger-glue-job"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "python3.9"
  s3_bucket        = aws_s3_bucket.output_bucket.id
  s3_key           = aws_s3_object.lambda_exe_script_zip.key

  environment {
    variables = {
        GLUE_JOB_NAME = "my-etl-job"
    }
  }
}

resource "aws_lambda_function" "query_athena" {
  function_name = "query-athena"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "python3.9"
  s3_bucket        = aws_s3_bucket.output_bucket.id
  s3_key           = aws_s3_object.lambda_api_script_zip.key
}

resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.trigger_glue_job.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.input_bucket.arn
}