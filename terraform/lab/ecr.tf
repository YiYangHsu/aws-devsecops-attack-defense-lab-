resource "aws_ecr_repository" "app" {
  name                 = "devsecops-lab-app"
  image_tag_mutability = "IMMUTABLE"

  force_delete = true
  encryption_configuration {
    encryption_type = "AES256"
  }
}

resource "aws_ecr_registry_scanning_configuration" "main" {
  scan_type = "BASIC"

  rule {
    scan_frequency = "SCAN_ON_PUSH"

    repository_filter {
      filter      = "devsecops-lab-app"
      filter_type = "WILDCARD"
    }
  }
}