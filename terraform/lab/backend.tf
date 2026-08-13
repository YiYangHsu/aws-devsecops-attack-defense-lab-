terraform {
  backend "s3" {
    bucket       = "devsecops-attack-defense-tfstate-472353357025"
    key          = "lab/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}