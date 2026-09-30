output "ecr_repository_url" {
  description = "URL of the ECR repository for the application"

  value = aws_ecr_repository.app.repository_url
}

output "vpc_id" {
  description = "ID of the security lab VPC"
  value       = aws_vpc.lab.id
}

output "public_subnet_id" {
  description = "ID of the public subnet used by the Fargate workload"
  value       = aws_subnet.public.id
}

output "app_security_group_id" {
  description = "Security group used by the application workload"
  value       = aws_security_group.app.id
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.lab.name
}

output "cloudwatch_log_group_name" {
  description = "CloudWatch log group used by the ECS application"
  value       = aws_cloudwatch_log_group.app.name
}

output "ecs_task_execution_role_arn" {
  description = "IAM role used by ECS to pull images and publish logs"
  value       = aws_iam_role.ecs_task_execution.arn
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.app.name
}

output "ecs_task_definition_arn" {
  description = "ARN of the ECS task definition"
  value       = aws_ecs_task_definition.app.arn
}

output "iam_lab_bucket_name" {
  description = "Disposable S3 bucket used for IAM attack-surface testing"
  value       = aws_s3_bucket.iam_lab.bucket
}

output "iam_lab_allowed_object" {
  description = "Object that will remain accessible after least-privilege remediation"
  value       = aws_s3_object.allowed_test_data.key
}

output "ecs_task_role_arn" {
  description = "IAM role used by the application running inside ECS"
  value       = aws_iam_role.ecs_task.arn
}

output "cloudtrail_name" {
  description = "CloudTrail used for Week 7 security telemetry"
  value       = aws_cloudtrail.security.name
}

output "cloudtrail_log_group_name" {
  description = "CloudWatch log group receiving CloudTrail events"
  value       = aws_cloudwatch_log_group.cloudtrail.name
}

output "cloudtrail_s3_bucket_name" {
  description = "Disposable S3 bucket storing CloudTrail log files"
  value       = aws_s3_bucket.cloudtrail_logs.bucket
}