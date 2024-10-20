resource "aws_iam_role" "glue_role" {
  name = "glue-job-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "glue.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "glue_s3_policy" {
  name = "glue-s3-permissions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::my-input-bucket-tech-chall",
          "arn:aws:s3:::my-input-bucket-tech-chall/*"
        ]
      },
      {
        Action = [
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::my-output-bucket-tech-chall",
          "arn:aws:s3:::my-output-bucket-tech-chall/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "glue_policy_attachment" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_s3_policy.arn
}

resource "aws_glue_job" "etl_job" {
  name        = "my-etl-job"
  role_arn    = aws_iam_role.glue_role.arn
  worker_type = "G.1X"
  number_of_workers = 5
  command {
    name            = "glueetl"
    script_location = "s3://script/script.py" 
  }
}
