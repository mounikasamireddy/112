resource "kubernetes_deployment" "nodejs" {
  metadata {
    name = "nodejs"
    namespace = "${local.namespace}"

    labels {
      app = "nodejs"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels {
        app = "nodejs"
      }
    }

    template {
      metadata {
        labels {
          app = "nodejs"
        }
      }

      spec {
        container {
          name  = "nodejs"
          image = "mounikavenna1281991/nodejs"

          port {
            container_port = 3001
          }
        }

      }
    }
  }
}
