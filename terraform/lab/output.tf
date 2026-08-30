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