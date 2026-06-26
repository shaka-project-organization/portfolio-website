terraform {
  backend "s3" {
    bucket         = "shaka-bank-project-s3"
    key            = "portfolio/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true

  }
}
