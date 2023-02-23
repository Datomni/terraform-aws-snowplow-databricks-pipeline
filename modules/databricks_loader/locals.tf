locals {
  config = templatefile("${path.module}/templates/config.hocon.tftpl",
    {
      region               = data.aws_region.current.name
      message_queue        = var.message_queue,
      databricks_host      = var.databricks_host,
      databricks_password  = var.databricks_password,
      databricks_schema    = var.databricks_schema,
      databricks_port      = var.databricks_port,
      databricks_http_path = var.databricks_http_path,
      iam_role_arn         = aws_iam_role.iam_role_s3.arn
  })

  iglu_resolver = templatefile("${path.module}/templates/iglu_resolver.json.tftpl",
    {
      iglu_server_url    = var.iglu_server_url,
      iglu_server_apikey = var.iglu_server_apikey
  })

  user_data = templatefile("${path.module}/templates/user-data.sh.tftpl", {
    config                    = local.config
    iglu_resolver             = local.iglu_resolver
    cloudwatch_log_group_name = aws_cloudwatch_log_group.log_group.name
  })
}
