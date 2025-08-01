# GKE cluster
resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  project  = var.project
  location = var.zone

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name
  networking_mode = "VPC_NATIVE"
  ip_allocation_policy {}
  deletion_protection = false
}

# Separately Managed Node Pool
resource "google_container_node_pool" "primary_nodes" {
  project    = var.project
  name       = "${google_container_cluster.primary.name}-node-pool"
  location   = var.zone
  cluster    = google_container_cluster.primary.name
  node_count = 3


  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      env = var.project
    }

    #preemptible  = true
    machine_type = "e2-standard-2"
    tags         = ["gke-node"]
    # disk_size_gb = "80"
    disk_type = "pd-standard" # Quota errors with SSD on europe-west1
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}

# Retrieve an access token as the Terraform runner

provider "kubernetes" {
  host  = "https://${google_container_cluster.primary.endpoint}"
  token = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(
    google_container_cluster.primary.master_auth.0.cluster_ca_certificate,
  )
}

resource "kubernetes_secret" "mysql-secrets" {
  metadata {
    name = "mysql-secrets"
    }
  data = {
    mysql-root-password = var.mysqlRootPassword
    }
}

resource "kubernetes_secret" "neo4j-secrets" {
  metadata {
    name = "neo4j-secrets"
    }
  data = {
    neo4j-password = var.neo4jPassword
    }
}

resource "kubernetes_secret" "datahub-users-secret" {
  metadata {
    name = "datahub-users-secret"
    }
  data = {
    "user.props" = "${file("user.props")}"
    }
}
# Ingress
resource "kubernetes_ingress_v1" "datahub_ingress" {
  depends_on = [
    helm_release.datahub
  ]
  metadata {
    name = "datahub-frontend"
    namespace = "default"
  }

  spec {
    default_backend {
      service {
        name = "datahub-datahub-frontend"
        port {
          number = 9002
        }
      }
    }

    rule {
      http {
        path {
          backend {
            service {
              name = "datahub-datahub-frontend"
              port {
                number = 9002
              }
            }
          }
          path_type = "ImplementationSpecific"
          path = ""
        }
      }
      host = "gcp.datahubproject.io" # Change this to your domain
    }
  }
}
