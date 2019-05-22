resource "kubernetes_service" "svc" {
  metadata {
    name      = "svc"
    namespace = "${local.namespace}"
    labels {
      app = "nginx"
    }
  }

  spec {
    port {
      name        = "svc"
      protocol    = "TCP"
      port        = 80
      target_port = "80"
    }

    selector {
      app = "nginx"
    }

    type = "LoadBalancer"
  }
}

