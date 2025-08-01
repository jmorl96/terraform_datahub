provider "helm" {
  kubernetes = {
    host                   = "https://${google_container_cluster.primary.endpoint}"
    token                  = data.google_client_config.provider.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)
    exec = {
            api_version = "client.authentication.k8s.io/v1beta1"
            command     = "gke-gcloud-auth-plugin"
        }
  }
}

resource "helm_release" "datahub_prerequisites" {
  name       = "prerequisites"
  repository = "https://helm.datahubproject.io/"
  chart      = "datahub-prerequisites"
  timeout = 5400
}
resource "helm_release" "datahub" {
  name       = "datahub"
  repository = "https://helm.datahubproject.io/"
  chart      = "datahub"
  values = [
    "${file("datahub.yaml")}"
  ]
  timeout = 5400

  depends_on = [
    helm_release.datahub_prerequisites
  ]
}