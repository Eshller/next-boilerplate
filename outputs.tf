output "s3_bucket_name" {
  description = "Name of the S3 bucket for static assets"
  value       = aws_s3_bucket.static_assets.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket for static assets"
  value       = aws_s3_bucket.static_assets.arn
}

output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.static_assets.id
}

output "cloudfront_distribution_arn" {
  description = "ARN of the CloudFront distribution"
  value       = aws_cloudfront_distribution.static_assets.arn
}

output "cloudfront_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.static_assets.domain_name
}

output "cloudfront_hosted_zone_id" {
  description = "Hosted zone ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.static_assets.hosted_zone_id
}

# Conditional outputs for SSR resources
output "vpc_id" {
  description = "ID of the VPC (if SSR is enabled)"
  value       = var.enable_ssr ? aws_vpc.main[0].id : null
}

output "public_subnet_ids" {
  description = "IDs of the public subnets (if SSR is enabled)"
  value       = var.enable_ssr ? aws_subnet.public[*].id : null
}

output "ecs_cluster_id" {
  description = "ID of the ECS cluster (if SSR is enabled)"
  value       = var.enable_ssr ? aws_ecs_cluster.main[0].id : null
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster (if SSR is enabled)"
  value       = var.enable_ssr ? aws_ecs_cluster.main[0].arn : null
}

output "ecs_service_name" {
  description = "Name of the ECS service (if SSR is enabled)"
  value       = var.enable_ssr ? aws_ecs_service.app[0].name : null
}

output "load_balancer_dns_name" {
  description = "DNS name of the load balancer (if SSR is enabled)"
  value       = var.enable_ssr ? aws_lb.ssr[0].dns_name : null
}

output "load_balancer_zone_id" {
  description = "Hosted zone ID of the load balancer (if SSR is enabled)"
  value       = var.enable_ssr ? aws_lb.ssr[0].zone_id : null
}

output "ecs_execution_role_arn" {
  description = "ARN of the ECS execution role (if SSR is enabled)"
  value       = var.enable_ssr ? aws_iam_role.ecs_execution[0].arn : null
}

# Deployment information
output "deployment_url" {
  description = "URL where the application is deployed"
  value       = "https://${aws_cloudfront_distribution.static_assets.domain_name}"
}

output "aws_region" {
  description = "AWS region where resources are deployed"
  value       = var.aws_region
}

output "project_name" {
  description = "Name of the project"
  value       = var.project_name
}
