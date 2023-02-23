variable "name" {
  description = "Application name"
  type        = string
}

variable "vpc_id" {
  description = "The VPC to deploy Loader within"
  type        = string
}

variable "subnet_ids" {
  description = "The list of subnets to deploy Loader across"
  type        = list(string)
}

variable "ssh_key_name" {
  description = "The name of the SSH key-pair to attach to all EC2 nodes deployed"
  type        = string
}

variable "message_queue" {
  description = "SQS queue name"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket with transformed snowplow events"
  type        = string
}

variable "associate_public_ip_address" {
  description = "Whether to assign a public ip address to this instance"
  type        = bool
  default     = true
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

variable "ssh_ip_allowlist" {
  description = "The list of CIDR ranges to allow SSH traffic from"
  type        = list(any)
  default     = ["0.0.0.0/0"]
}

variable "iam_permissions_boundary" {
  description = "The permissions boundary ARN to set on IAM roles created"
  default     = ""
  type        = string
}

variable "instance_type" {
  description = "The instance type to use"
  type        = string
  default     = "t3.micro"
}

variable "tags" {
  description = "The tags to append to the resources in this module"
  default     = {}
  type        = map(string)
}
