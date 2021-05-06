/*
  The backend Google Cloud Storage (GCS) is used to store the Terraform state.
  This makes sure that the Terraform state is not lost because it is stored on the local file system and allows better collaboration between developers.
  See https://www.terraform.io/docs/language/settings/backends/gcs.html
*/
terraform {
  backend "gcs" {
    bucket  = "adept-bond-312518"
    prefix  = "terraform/state"
  }
}
