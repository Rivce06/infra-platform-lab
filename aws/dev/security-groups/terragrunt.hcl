include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "tfr:///terraform-aws-modules/security-group/aws?version=5.1.0"
}

dependency "vpc" {
  config_path = "../vpc"
}

inputs = {
  name        = "k3s-lab-sg"
  description = "SG K3s & monitoring"
  vpc_id      = dependency.vpc.outputs.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 6443
      to_port     = 6443
      protocol    = "tcp"
      description = "Kubernetes API"
      cidr_blocks = "10.0.0.0/16"
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "HTTP"
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
      description = "Node Exporter"
      cidr_blocks = "10.0.0.0/16"
    }
  ]

  egress_rules = ["all-all"]

  tags = {
    Component = "security"
  }
}