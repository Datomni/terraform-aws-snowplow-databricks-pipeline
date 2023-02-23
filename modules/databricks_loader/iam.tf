# EC2 role
resource "aws_iam_role" "iam_role" {
  name        = var.name
  description = "Allows the Databricks Loader nodes to access required services"
  tags        = var.tags

  assume_role_policy = <<EOF
{
  "Version" : "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": [ "ec2.amazonaws.com" ]},
      "Action": [ "sts:AssumeRole" ]
    }
  ]
}
EOF

  permissions_boundary = var.iam_permissions_boundary
}

resource "aws_iam_policy" "iam_policy" {
  name = var.name
  tags = var.tags

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "sqs:DeleteMessage",
          "sqs:GetQueueUrl",
          "sqs:ListQueues",
          "sqs:ChangeMessageVisibility",
          "sqs:SendMessageBatch",
          "sqs:ReceiveMessage",
          "sqs:SendMessage",
          "sqs:DeleteMessageBatch",
          "sqs:ChangeMessageVisibilityBatch",
        ],
        Resource = [
          "arn:aws:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.message_queue}"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "logs:PutLogEvents",
          "logs:CreateLogStream",
          "logs:DescribeLogStreams"
        ],
        Resource = [
          "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${aws_cloudwatch_log_group.log_group.name}:*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket",
        ],
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_name}"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListObject",
          "s3:DeleteObject"
        ],
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_name}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "iam:ListRoles",
          "sts:AssumeRole"
        ],
        Resource = [
          aws_iam_role.iam_role_s3.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "policy_attachment" {
  role       = aws_iam_role.iam_role.name
  policy_arn = aws_iam_policy.iam_policy.arn
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = var.name
  role = aws_iam_role.iam_role.name
}


# S3 Access role to be assumed by loader
resource "aws_iam_role" "iam_role_s3" {
  name        = "${var.name}-assume-role"
  description = "Allows the Databricks Loader to access data in s3"
  tags        = var.tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = data.aws_caller_identity.current.account_id
        },
        Action = ["sts:AssumeRole"]
      }
    ]
  })

  permissions_boundary = var.iam_permissions_boundary
}

resource "aws_iam_policy" "iam_policy_s3" {
  name = "${var.name}-assume-policy"
  tags = var.tags

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject*",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ],
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_name}",
          "arn:aws:s3:::${var.s3_bucket_name}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "policy_attachment_s3" {
  role       = aws_iam_role.iam_role_s3.name
  policy_arn = aws_iam_policy.iam_policy_s3.arn
}
