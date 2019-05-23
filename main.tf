############################## To create the node js #######################
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
##################### To create nginx pod #################
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
############################## To create mongoDB #################################
resource "kubernetes_deployment" "mongo_deployment" {
  metadata {
    name = "mongo-deployment"
    namespace = "${local.namespace}"
    labels {
      app = "mongo"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels {
        app = "mongo"
      }
    }

    template {
      metadata {
        labels {
          app = "mongo"
        }
      }

      spec {
        container {
          name  = "mongo"
          image = "mongo"

          port {
            container_port = 9090
          }
        }

      }
    }
  }
}

#################### To create nginx service #########################
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

############################# To create nodejs service ###########################
resource "kubernetes_service" "nodejssvc" {
  metadata {
    name      = "nodejssvc"
    namespace = "${local.namespace}"
    labels {
      app = "nodejs"
    }
  }
  spec {
    port {
      name        = "nodejssvc"
      protocol    = "TCP"
      port        = 3001
      target_port = "3001"
    }
    selector {
      app = "nodejs"
    }
  }
}

################ to create a name space ###############################
resource "kubernetes_namespace" "default" {
  metadata {
    name = "${local.namespace}"
    }
}
locals {
  original_tags = "${join(var.delimiter, compact(concat(list(var.namespace, var.stage, var.name), var.attributes)))}"
}

locals {
  convert_case = "${var.convert_case == "true" ? true : false }"
}

locals {
  transformed_tags = "${local.convert_case == true ? lower(local.original_tags) : local.original_tags}"
}

locals {
  enabled = "${var.enabled == "true" ? true : false }"

  id = "${local.enabled == true ? local.transformed_tags : ""}"

  name       = "${local.enabled == true ? (local.convert_case == true ? lower(format("%v", var.name)) : format("%v", var.name)) : ""}"
  namespace  = "${local.enabled == true ? (local.convert_case == true ? lower(format("%v", var.namespace)) : format("%v", var.namespace)) : ""}"
  stage      = "${local.enabled == true ? (local.convert_case == true ? lower(format("%v", var.stage)) : format("%v", var.stage)) : ""}"
  attributes = "${local.enabled == true ? (local.convert_case == true ? lower(format("%v", join(var.delimiter, compact(var.attributes)))) : format("%v", join(var.delimiter, compact(var.attributes)))): ""}"

  # Merge input tags with our tags.
  # Note: `Name` has a special meaning in AWS and we need to disamgiuate it by using the computed `id`
  tags = "${
      merge( 
        map(
          "Name", "${local.id}",
          "Namespace", "${local.namespace}",
          "Stage", "${local.stage}"
        ), var.tags
      )
 }"
}

################################ To pass the variables ###############################
variable "namespace" {
  description = "Namespace, which could be your organization name, e.g. `cp` or `cloudposse`"
}

variable "stage" {
  description = "Stage, e.g. `prod`, `staging`, `dev`, or `test`"
}

variable "name" {
  description = "Solution name, e.g. `app`"
}

variable "enabled" {
  description = "Set to false to prevent the module from creating any resources"
  default     = "true"
}

variable "delimiter" {
  type        = "string"
  default     = "-"
  description = "Delimiter to be used between `namespace`, `name`, `stage` and `attributes`"
}

variable "attributes" {
  type        = "list"
  default     = []
  description = "Additional attributes, e.g. `1`"
}

variable "tags" {
  type        = "map"
  default     = {}
  description = "Additional tags (e.g. `map(`BusinessUnit`,`XYZ`)"
}

variable "convert_case" {
  description = "Convert fields to lower case"
  default     = "true"
}

############################ outputs ##########################
output "id" {
  value       = "${local.id}"
  description = "Disambiguated ID"
}

output "name" {
  value       = "${local.name}"
  description = "Normalized name"
}

output "namespace" {
  value       = "${local.namespace}"
  description = "Normalized namespace"
}

output "stage" {
  value       = "${local.stage}"
  description = "Normalized stage"
}

output "attributes" {
  value       = "${local.attributes}"
  description = "Normalized attributes"
}

output "tags" {
  value       = "${local.tags}"
  description = "Normalized Tag map"
}
