output "collector_dns_name" {
  description = "The ALB dns name for the Pipeline Collector"
  value       = module.collector_lb.dns_name
}
