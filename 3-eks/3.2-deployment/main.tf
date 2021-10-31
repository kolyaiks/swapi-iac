terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.20.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.1"
    }
  }
}

data "terraform_remote_state" "eks" {
  backend = "local"

  config = {
    path = "../3.1-cluster/terraform.tfstate"
  }
}

# Retrieve EKS cluster information
provider "aws" {
  region = data.terraform_remote_state.eks.outputs.region
}

data "aws_eks_cluster" "cluster" {
  name = data.terraform_remote_state.eks.outputs.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      data.aws_eks_cluster.cluster.name
    ]
  }
}

#====== Deployment ==============

resource "kubernetes_deployment" "swapi_deployment" {
  metadata {
    name = "swapi-deployment"
    labels = {
      App = "swapi"
    }
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        App = "swapi"
      }
    }
    template {
      metadata {
        labels = {
          App = "swapi"
        }
      }
      spec {
        container {
          image = var.docker_image
          name  = "swapi-pod"

          port {
            container_port = 8080
          }

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
        }
      }
    }
  }
}

#=========== Service ============

resource "kubernetes_service" "swapi_service" {
  metadata {
    name = "swapi-service"
  }
  spec {
    selector = {
      App = kubernetes_deployment.swapi_deployment.spec.0.template.0.metadata[0].labels.App
    }
    port {
      port        = 80 # on service (LB)
      target_port = 8080 # on pod
    }

    type = "LoadBalancer"
  }
}