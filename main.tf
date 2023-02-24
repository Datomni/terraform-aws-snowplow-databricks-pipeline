# Create S3 bucket
module "s3_pipeline_bucket" {
  source  = "snowplow-devops/s3-bucket/aws"
  version = "0.2.0"

  bucket_name = var.s3_bucket_name

  tags = var.tags
}

# Setup key for SSH into deployed servers
resource "tls_private_key" "tls_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "pipeline" {
  key_name   = "snowplow-pipeline"
  public_key = tls_private_key.tls_key.public_key_openssh
}

# Deploy Kinesis streams
module "raw_stream" {
  source  = "snowplow-devops/kinesis-stream/aws"
  version = "0.3.0"

  name = "snowplow-raw-stream"

  tags = var.tags
}

module "bad_1_stream" {
  source  = "snowplow-devops/kinesis-stream/aws"
  version = "0.3.0"

  name = "snowplow-bad-1-stream"
  tags = var.tags
}

module "enriched_stream" {
  source  = "snowplow-devops/kinesis-stream/aws"
  version = "0.3.0"

  name = "snowplow-enriched-stream"

  tags = var.tags
}

module "bad_2_stream" {
  source  = "snowplow-devops/kinesis-stream/aws"
  version = "0.3.0"

  name = "snowplow-bad-2-stream"

  tags = var.tags
}

# Deploy Collector stack
module "collector_lb" {
  source  = "snowplow-devops/alb/aws"
  version = "0.2.0"

  name              = "snowplow-collector-lb"
  vpc_id            = var.vpc_id
  subnet_ids        = var.public_subnet_ids
  health_check_path = "/health"

  ssl_certificate_arn     = var.ssl_information.certificate_arn
  ssl_certificate_enabled = var.ssl_information.enabled

  tags = var.tags
}

module "collector_kinesis" {
  source  = "snowplow-devops/collector-kinesis-ec2/aws"
  version = "0.4.0"

  name       = "snowplow-collector-server"
  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  collector_lb_sg_id = module.collector_lb.sg_id
  collector_lb_tg_id = module.collector_lb.tg_id
  ingress_port       = module.collector_lb.tg_egress_port
  good_stream_name   = module.raw_stream.name
  bad_stream_name    = module.bad_1_stream.name

  ssh_key_name                = aws_key_pair.pipeline.key_name
  associate_public_ip_address = var.associate_public_ip_address
  iam_permissions_boundary    = var.iam_permissions_boundary

  tags = var.tags
}

# Deploy Enrichment
module "enrich_kinesis" {
  source  = "snowplow-devops/enrich-kinesis-ec2/aws"
  version = "0.4.0"

  name                 = "snowplow-enrich-server"
  vpc_id               = var.vpc_id
  subnet_ids           = var.private_subnet_ids
  in_stream_name       = module.raw_stream.name
  enriched_stream_name = module.enriched_stream.name
  bad_stream_name      = module.bad_1_stream.name

  ssh_key_name                = aws_key_pair.pipeline.key_name
  associate_public_ip_address = var.associate_public_ip_address
  iam_permissions_boundary    = var.iam_permissions_boundary

  # Linking in the custom Iglu Server here
  custom_iglu_resolvers = local.custom_iglu_resolvers

  kcl_write_max_capacity = var.pipeline_kcl_write_max_capacity

  tags = var.tags
}

resource "aws_sqs_queue" "message_queue" {
  content_based_deduplication = true
  name                        = "snowplow-sf-loader.fifo"
  fifo_queue                  = true
  kms_master_key_id           = "alias/aws/sqs"
}

# Save raw, enriched and bad data to Amazon S3
module "s3_loader_raw" {
  source  = "snowplow-devops/s3-loader-kinesis-ec2/aws"
  version = "0.3.1"

  name             = "snowplow-s3-loader-raw-server"
  vpc_id           = var.vpc_id
  subnet_ids       = var.private_subnet_ids
  in_stream_name   = module.raw_stream.name
  bad_stream_name  = module.bad_1_stream.name
  s3_bucket_name   = module.s3_pipeline_bucket.id
  s3_object_prefix = "raw/"

  ssh_key_name                = aws_key_pair.pipeline.key_name
  associate_public_ip_address = var.associate_public_ip_address
  iam_permissions_boundary    = var.iam_permissions_boundary

  kcl_write_max_capacity = var.pipeline_kcl_write_max_capacity

  tags = var.tags
}

module "s3_loader_bad" {
  source  = "snowplow-devops/s3-loader-kinesis-ec2/aws"
  version = "0.3.1"

  name             = "snowplow-s3-loader-bad-server"
  vpc_id           = var.vpc_id
  subnet_ids       = var.private_subnet_ids
  in_stream_name   = module.bad_1_stream.name
  bad_stream_name  = module.bad_2_stream.name
  s3_bucket_name   = module.s3_pipeline_bucket.id
  s3_object_prefix = "bad/"

  ssh_key_name                = aws_key_pair.pipeline.key_name
  associate_public_ip_address = var.associate_public_ip_address
  iam_permissions_boundary    = var.iam_permissions_boundary

  kcl_write_max_capacity = var.pipeline_kcl_write_max_capacity

  tags = var.tags
}

module "s3_loader_enriched" {
  source  = "snowplow-devops/s3-loader-kinesis-ec2/aws"
  version = "0.3.1"

  name             = "snowplow-s3-loader-enriched-server"
  vpc_id           = var.vpc_id
  subnet_ids       = var.private_subnet_ids
  in_stream_name   = module.enriched_stream.name
  bad_stream_name  = module.bad_1_stream.name
  s3_bucket_name   = module.s3_pipeline_bucket.id
  s3_object_prefix = "enriched/"

  ssh_key_name                = aws_key_pair.pipeline.key_name
  associate_public_ip_address = var.associate_public_ip_address
  iam_permissions_boundary    = var.iam_permissions_boundary

  kcl_write_max_capacity = var.pipeline_kcl_write_max_capacity

  tags = var.tags
}

# Setup transformer to save transformed data to S3
module "transformer_kinesis" {
  source  = "snowplow-devops/transformer-kinesis-ec2/aws"
  version = "0.2.2"

  name       = "snowplow-transformer-kinesis-enriched-server"
  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  stream_name             = module.enriched_stream.name
  s3_bucket_name          = module.s3_pipeline_bucket.id
  s3_bucket_object_prefix = "transformed/good"
  window_period_min       = var.transformer_window_period_min
  sqs_queue_name          = aws_sqs_queue.message_queue.name

  transformation_type = "widerow"
  widerow_file_format = "parquet"

  ssh_key_name                = aws_key_pair.pipeline.key_name
  associate_public_ip_address = var.associate_public_ip_address
  iam_permissions_boundary    = var.iam_permissions_boundary

  kcl_write_max_capacity = var.pipeline_kcl_write_max_capacity

  tags = var.tags
}

# Load transformed data to Databricks
module "databricks_loader" {
  source = "./modules/databricks_loader"

  name           = "snowplow-databricks-loader-transformed-good-server"
  vpc_id         = var.vpc_id
  subnet_ids     = var.public_subnet_ids
  message_queue  = aws_sqs_queue.message_queue.name
  s3_bucket_name = var.s3_bucket_name

  databricks_host      = var.databricks_host
  databricks_http_path = var.databricks_http_path
  databricks_password  = var.databricks_password
  databricks_port      = var.databricks_port
  databricks_schema    = var.databricks_schema

  iglu_server_apikey = var.iglu_server_apikey
  iglu_server_url    = var.iglu_server_url

  ssh_key_name                = aws_key_pair.pipeline.key_name
  associate_public_ip_address = var.associate_public_ip_address
  iam_permissions_boundary    = var.iam_permissions_boundary

  tags = var.tags
}
