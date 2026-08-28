terraform {
  backend "gcs" {
    bucket = "kirtuos-poc-tf-state"
    prefix = "terraform/state"
  }
}