/*
  This file contains shared variables required for all resources provisioned through Terraform
*/
variable "project_id" {
  description = <<-EOF
  Components will be deployed to this GCP project.
  EOF
  default = "adept-bond-312518"
}

variable "region" {
  description = <<-EOF
  GCP Region where the components will be deployed.
  EOF
  default = "europe-west3"
}

variable "zones" {
  description = "Zone where the GKE cluster will be deployed."
  default = ["europe-west3-a"]
}

