/*
  This files mainly contains the deployments of the observability tools on the already provisioned infrastructure through the Helm provider
*/

// Helm provider config
// Make sure that the correct kube credentials are stored in the directory
// The Terraform output get_credentials could be used to retrieve the kube credentials
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

// Deploys observability tools through Helm
resource "helm_release" "observability_tools" {
  name = "observability-tools"

  chart = "./../helm"

  depends_on = [
    google_container_node_pool.primary_nodes
  ]
}


