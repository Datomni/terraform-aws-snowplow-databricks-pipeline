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

variable "associate_public_ip_address" {
  description = "Whether to assign a public ip address to the resource. Required if resources are created in a public subnet"
  type        = bool
  default     = false
}

variable "iam_permissions_boundary" {
  description = "The permissions boundary ARN to set on IAM roles created"
  type        = string
  default     = ""
}

variable "ssl_information" {
  description = "The ARN of an Amazon Certificate Manager certificate to bind to the load balancer"
  type = object({
    enabled         = bool
    certificate_arn = string
  })
  default = {
    certificate_arn = ""
    enabled         = false
  }
}

variable "pipeline_kcl_write_max_capacity" {
  description = "Increasing this is important to increase throughput at very high pipeline volumes"
  type        = number
  default     = 50
}

variable "transformer_window_period_min" {
  description = "Frequency to emit loading finished message - 5,10,15,20,30,60 etc minutes"
  type        = number
  default     = 5
}


variable "tags" {
  description = "The tags to append to the resources"
  type        = map(string)
  default     = {}
}
