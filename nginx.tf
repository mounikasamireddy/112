resource "kubernetes_deployment" "nginx" {
  metadata {
    name = "nginx"
    namespace = "${local.namespace}"

    labels {
      app = "nginx"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels {
        app = "nginx"
      }
    }

    template {
      metadata {
        labels {
          app = "nginx"
        }
      }

      spec {
        container {
          name  = "nginx"
          image = "mounikavenna1281991/nginx"

          port {
            container_port = 80
          }
        }

      }
    }
  }
}
