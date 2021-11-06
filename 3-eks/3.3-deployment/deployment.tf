resource "kubernetes_deployment" "swapi_deployment" {
  metadata {
    name   = "swapi-deployment"
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
        #serviceAccountName: someName
        container {
          image = var.docker_image
          name  = "swapi-pod"

          port {
            container_port = 8080
          }

          env {
            name  = "SPRING_PROFILES_ACTIVE"
            value = "aws"
          }

          env {
            name  = "DB_ENDPOINT"
            value = data.terraform_remote_state.rds.outputs.db_instance_address
          }

          env {
            name  = "DB_USER"
            value = data.terraform_remote_state.rds.outputs.db_user
          }

          env {
            name  = "DB_PASSWORD"
            value = data.terraform_remote_state.rds.outputs.db_password
          }

          resources {
            limits   = {
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