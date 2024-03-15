resource "kubernetes_deployment" "sejal-docker" {
  metadata {
    name = "sejal-docker"
    labels = {
      nome = "sejal-docker"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        name = "sejal-docker"
      }
    }

    template {
      metadata {
        labels = {
          name = "sejal-docker"
        }
      }

      spec {
        container {
          image = "987770788832.dkr.ecr.us-east-1.amazonaws.com/sejal_docker_image"
          name  = "sejal-docker"

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/WeatherForecast/"
              port = 8080
            }

            initial_delay_seconds = 20
            period_seconds        = 5
          }
        }
      }
    }
  }

  depends_on = [
    aws_eks_cluster.eks_cluster
  ]
}

resource "kubernetes_service" "LoadBalancer" {
  metadata {
    name = "lb-sejal-docker"
  }
  spec {
    selector = {
      nome = "sejal-docker"
    }
    port {
      port = 80
      target_port = 8080
    }
    type = "LoadBalancer"
  }

  depends_on = [
    kubernetes_deployment.sejal-docker
  ]
}

data "kubernetes_service" "nomeDNS" {
    metadata {
      name = "lb-sejal-docker"
    }

    depends_on = [
    aws_eks_cluster.eks_cluster
  ]
}

output "URL" {
  value = data.kubernetes_service.nomeDNS.status
}

data "aws_eks_cluster" "default" {
  name = var.cluster_name

  depends_on = [
    aws_eks_cluster.eks_cluster
  ]
}

data "aws_eks_cluster_auth" "default" {
  name = var.cluster_name

  depends_on = [
    aws_eks_cluster.eks_cluster
  ]
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.default.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.default.token
}