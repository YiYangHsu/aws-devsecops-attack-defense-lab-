resource "aws_ecs_cluster" "lab" {
  name = "devsecops-lab-cluster"

  tags = {
    Name = "devsecops-lab-cluster"
  }
}

resource "aws_ecs_task_definition" "app" {
  family                   = "devsecops-lab-app"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = "256"
  memory = "512"

  execution_role_arn = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name      = "devsecops-lab-app"
      image     = "${aws_ecr_repository.app.repository_url}:v3"
      essential = true

      portMappings = [
        {
          containerPort = 8080
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          awslogs-group         = aws_cloudwatch_log_group.app.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "app"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "app" {
  name            = "devsecops-lab-service"
  cluster         = aws_ecs_cluster.lab.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets = [
      aws_subnet.public.id
    ]

    security_groups = [
      aws_security_group.app.id
    ]

    assign_public_ip = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.ecs_task_execution
  ]
}