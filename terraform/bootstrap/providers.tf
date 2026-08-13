provider "aws" {
  region = var.aws_region
  profile = var.aws_profile

  default_tags {
    tags = {
      Project     = "aws-devsecops-attack-defense-lab"
      ManagedBy   = "Terraform"
      Envrionment = "security-lab"
    }
  }
}