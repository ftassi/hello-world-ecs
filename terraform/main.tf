provider "aws" {
  region = "eu-west-1"
}

terraform {
  backend "s3" {
    bucket = "ftassi-terraform-state"
    key    = "terraform.tfstate"
    region = "eu-west-1"
  }
}
