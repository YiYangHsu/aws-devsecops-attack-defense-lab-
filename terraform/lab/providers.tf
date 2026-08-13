provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "aws-devsecops-attack-defense-lab"
      ManagedBy   = "Terraform"
      Environment = "security-lab"
    }
  }
}