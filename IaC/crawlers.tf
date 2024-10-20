resource "aws_iam_role" "crawler_role" {
  name = "glue-crawler-role"

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

resource "aws_iam_policy" "crawler_s3_policy" {
  name = "crawler-s3-permissions"

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
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "crawler_policy_attachment" {
  role       = aws_iam_role.crawler_role.name
  policy_arn = aws_iam_policy.crawler_s3_policy.arn
}

resource "aws_glue_crawler" "input_crawler" {
  name = "my-input-crawler"
  role = aws_iam_role.crawler_role.arn
  database_name = "tech_challenge_database" 
  table_prefix  = "input_" 
  s3_target {
    path = "s3://my-input-bucket-tech-chall"
  }
}

resource "aws_glue_crawler" "output_crawler" {
  name = "my-output-crawler"
  role = aws_iam_role.crawler_role.arn
  database_name = "tech_challenge_database"
  table_prefix  = "output_" 
  s3_target {
    path = "s3://my-output-bucket-tech-chall"
  }
}
