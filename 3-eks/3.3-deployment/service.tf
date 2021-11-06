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

    type = "NodePort"
  }
}