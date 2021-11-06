resource "kubernetes_ingress" "ingress" {
  metadata {
    name        = "swapi-ingress"
    annotations = {
      "alb.ingress.kubernetes.io/scheme" = "internet-facing"
      "kubernetes.io/ingress.class"      = "alb"
    }
  }

  spec {
    rule {
      http {
        path {
          path = "/*"
          backend {
            service_name = "swapi-service"
            service_port = 80
          }
        }
      }
    }
  }
}