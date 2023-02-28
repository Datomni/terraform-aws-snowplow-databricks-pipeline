# --- VPC Configuration
vpc_id             = "vpc-1234"
private_subnet_ids = ["subnet-1234a", "subnet-1234b", ]
public_subnet_ids  = ["subnet-1234c", "subnet-1234d", ]

# --- S3 Configuration
s3_bucket_name = "snowplow-data-bucket"

# --- Databricks Configuration
databricks_host      = "abc1.cloud.databricks.com"
databricks_password  = "12345678910"
databricks_schema    = "snowplow"
databricks_port      = 443
databricks_http_path = "sql/protocolv1/o/12345678910/1234-1234"

# --- Iglu Server Configuration
iglu_server_url    = "http://sp-iglu-lb-1234.us-east-1.elb.amazonaws.com"
iglu_server_apikey = "ABCD12345"
