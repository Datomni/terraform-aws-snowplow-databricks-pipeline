terraform {
  required_version = ">= 1.3.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.4.5"
    }
  }
}

module "snowplow-databricks-pipeline" {
  source = "Datomni/snowplow-databricks-pipeline/aws"

  vpc_id             = var.vpc_id
  private_subnet_ids = var.private_subnet_ids
  public_subnet_ids  = var.public_subnet_ids

  s3_bucket_name = var.s3_bucket_name

  databricks_host      = var.databricks_host
  databricks_password  = var.databricks_password
  databricks_schema    = var.databricks_schema
  databricks_port      = var.databricks_port
  databricks_http_path = var.databricks_http_path
  iglu_server_url      = var.iglu_server_url
  iglu_server_apikey   = var.iglu_server_apikey
}
