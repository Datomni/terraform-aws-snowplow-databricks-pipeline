# terraform-aws-snowplow-databricks-pipeline
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version    |
|------|------------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | \>= 1.3.5  |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | \>= 3.45.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | \>= 4.0.4  |

## Providers

| Name | Version    |
|------|------------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | \>= 3.45.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | \>= 4.0.4  |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bad_1_stream"></a> [bad\_1\_stream](#module\_bad\_1\_stream) | snowplow-devops/kinesis-stream/aws | 0.3.0 |
| <a name="module_bad_2_stream"></a> [bad\_2\_stream](#module\_bad\_2\_stream) | snowplow-devops/kinesis-stream/aws | 0.3.0 |
| <a name="module_collector_kinesis"></a> [collector\_kinesis](#module\_collector\_kinesis) | snowplow-devops/collector-kinesis-ec2/aws | 0.4.0 |
| <a name="module_collector_lb"></a> [collector\_lb](#module\_collector\_lb) | snowplow-devops/alb/aws | 0.2.0 |
| <a name="module_databricks_loader"></a> [databricks\_loader](#module\_databricks\_loader) | ./modules/databricks_loader | n/a |
| <a name="module_enrich_kinesis"></a> [enrich\_kinesis](#module\_enrich\_kinesis) | snowplow-devops/enrich-kinesis-ec2/aws | 0.4.0 |
| <a name="module_enriched_stream"></a> [enriched\_stream](#module\_enriched\_stream) | snowplow-devops/kinesis-stream/aws | 0.3.0 |
| <a name="module_raw_stream"></a> [raw\_stream](#module\_raw\_stream) | snowplow-devops/kinesis-stream/aws | 0.3.0 |
| <a name="module_s3_loader_bad"></a> [s3\_loader\_bad](#module\_s3\_loader\_bad) | snowplow-devops/s3-loader-kinesis-ec2/aws | 0.3.1 |
| <a name="module_s3_loader_enriched"></a> [s3\_loader\_enriched](#module\_s3\_loader\_enriched) | snowplow-devops/s3-loader-kinesis-ec2/aws | 0.3.1 |
| <a name="module_s3_loader_raw"></a> [s3\_loader\_raw](#module\_s3\_loader\_raw) | snowplow-devops/s3-loader-kinesis-ec2/aws | 0.3.1 |
| <a name="module_s3_pipeline_bucket"></a> [s3\_pipeline\_bucket](#module\_s3\_pipeline\_bucket) | snowplow-devops/s3-bucket/aws | 0.2.0 |
| <a name="module_transformer_kinesis"></a> [transformer\_kinesis](#module\_transformer\_kinesis) | snowplow-devops/transformer-kinesis-ec2/aws | 0.2.2 |

## Resources

| Name | Type |
|------|------|
| [aws_key_pair.pipeline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_sqs_queue.message_queue](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [tls_private_key.example](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_associate_public_ip_address"></a> [associate\_public\_ip\_address](#input\_associate\_public\_ip\_address) | Whether to assign a public ip address to the resource. Required if resources are created in a public subnet | `bool` | `false` | no |
| <a name="input_databricks_host"></a> [databricks\_host](#input\_databricks\_host) | Databricks Host | `string` | n/a | yes |
| <a name="input_databricks_http_path"></a> [databricks\_http\_path](#input\_databricks\_http\_path) | Databricks http path | `string` | n/a | yes |
| <a name="input_databricks_password"></a> [databricks\_password](#input\_databricks\_password) | Password for databricks\_loader\_user used by loader to perform loading | `string` | n/a | yes |
| <a name="input_databricks_port"></a> [databricks\_port](#input\_databricks\_port) | Databricks port | `number` | n/a | yes |
| <a name="input_databricks_schema"></a> [databricks\_schema](#input\_databricks\_schema) | Databricks schema name | `string` | n/a | yes |
| <a name="input_iam_permissions_boundary"></a> [iam\_permissions\_boundary](#input\_iam\_permissions\_boundary) | The permissions boundary ARN to set on IAM roles created | `string` | `""` | no |
| <a name="input_iglu_server_apikey"></a> [iglu\_server\_apikey](#input\_iglu\_server\_apikey) | Iglu Server API key | `string` | n/a | yes |
| <a name="input_iglu_server_url"></a> [iglu\_server\_url](#input\_iglu\_server\_url) | Iglu Server url/dns | `string` | n/a | yes |
| <a name="input_pipeline_kcl_write_max_capacity"></a> [pipeline\_kcl\_write\_max\_capacity](#input\_pipeline\_kcl\_write\_max\_capacity) | Increasing this is important to increase throughput at very high pipeline volumes | `number` | `50` | no |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | The list of private subnets to deploy resources across | `list(string)` | n/a | yes |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | The list of public subnets to deploy resources across | `list(string)` | n/a | yes |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | S3 bucket with transformed snowplow events | `string` | n/a | yes |
| <a name="input_ssl_information"></a> [ssl\_information](#input\_ssl\_information) | The ARN of an Amazon Certificate Manager certificate to bind to the load balancer | <pre>object({<br>    enabled         = bool<br>    certificate_arn = string<br>  })</pre> | <pre>{<br>  "certificate_arn": "",<br>  "enabled": false<br>}</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | The tags to append to the resources | `map(string)` | `{}` | no |
| <a name="input_transformer_window_period_min"></a> [transformer\_window\_period\_min](#input\_transformer\_window\_period\_min) | Frequency to emit loading finished message - 5,10,15,20,30,60 etc minutes | `number` | `5` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The VPC to deploy resources within | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->