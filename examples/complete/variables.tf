variable "vpc_id" {
  description = "The VPC to deploy resources within"
  type        = string
}

variable "private_subnet_ids" {
  description = "The list of private subnets to deploy resources across"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "The list of public subnets to deploy resources across"
  type        = list(string)
}

variable "s3_bucket_name" {
  description = "S3 bucket with transformed snowplow events"
  type        = string
}

variable "databricks_host" {
  description = "Databricks Host"
  type        = string
}

variable "databricks_password" {
  description = "Password for databricks_loader_user used by loader to perform loading"
  type        = string
  sensitive   = true
}

variable "databricks_schema" {
  description = "Databricks schema name"
  type        = string
}

variable "databricks_port" {
  description = "Databricks port"
  type        = number
}

variable "databricks_http_path" {
  description = "Databricks http path"
  type        = string
}

variable "iglu_server_url" {
  description = "Iglu Server url/dns"
  type        = string
}

variable "iglu_server_apikey" {
  description = "Iglu Server API key"
  type        = string
}
