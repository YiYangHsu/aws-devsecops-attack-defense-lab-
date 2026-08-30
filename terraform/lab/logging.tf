resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/devsecops-lab-app"
  retention_in_days = 7

  tags = {
    Name = "devsecops-lab-app-logs"
  }
}