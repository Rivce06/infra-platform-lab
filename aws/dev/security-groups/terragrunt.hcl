include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "tfr:///terraform-aws-modules/security-group/aws?version=5.1.0"
}

dependency "vpc" {
  config_path = "../vpc"
}

inputs = {
  name        = "k3s-lab-sg"
  description = "Fuego cruzado para K3s, ArgoCD y Monitoreo"
  vpc_id      = dependency.vpc.outputs.vpc_id

  # Reglas de Entrada (Ingress)
  ingress_with_cidr_blocks = [
    {
      from_port   = 6443
      to_port     = 6443
      protocol    = "tcp"
      description = "API de Kubernetes (Kubectl local)"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "HTTP (Ingress para ArgoCD/Grafana)"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "HTTPS"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 9100
      to_port     = 9100
      protocol    = "tcp"
      description = "Node Exporter (Metrics scraping)"
      cidr_blocks = "10.0.0.0/16" # Solo interno para seguridad
    }
  ]

  # Salida Total (Egress) - Vital para descargar imágenes de Docker y Helm charts
  egress_rules = ["all-all"]
}
