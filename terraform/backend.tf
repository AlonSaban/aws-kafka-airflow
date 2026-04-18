terraform {
  backend "s3" {
    bucket       = "my-tf-state-bucket"
    key          = "dataops/terraform.tfstate"
    region       = "eu-west-1"
    use_lockfile = true
  }
}
