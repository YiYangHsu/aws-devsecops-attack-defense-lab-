data "aws_iam_policy_document" "ecs_task_execution_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution" {
  name = "devsecops-lab-ecs-task-execution-role"

  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task" {
  name = "devsecops-lab-ecs-task-role"

  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

#data "aws_iam_policy_document" "ecs_task_s3_broad" {
#  statement {
#    sid    = "BroadAccessToLabBucket"
#    effect = "Allow"
#
#    actions = [
#      "s3:*"
#    ]

#    resources = [
#      aws_s3_bucket.iam_lab.arn,
#      "${aws_s3_bucket.iam_lab.arn}/*"
#    ]
#  }
#}

#resource "aws_iam_role_policy" "ecs_task_s3_broad" {
#  name = "devsecops-lab-broad-s3-policy"
#  role = aws_iam_role.ecs_task.id

#  policy = data.aws_iam_policy_document.ecs_task_s3_broad.json
#}

data "aws_iam_policy_document" "ecs_task_s3_least_privilege" {
  statement {
    sid    = "ReadOnlyAllowedLabObject"
    effect = "Allow"

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.iam_lab.arn}/allowed/test-data.txt"
    ]
  }
}

resource "aws_iam_role_policy" "ecs_task_s3_least_privilege" {
  name = "devsecops-lab-least-privilege-s3-policy"
  role = aws_iam_role.ecs_task.id

  policy = data.aws_iam_policy_document.ecs_task_s3_least_privilege.json
}