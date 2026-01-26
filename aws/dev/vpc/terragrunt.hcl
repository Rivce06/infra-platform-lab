include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "tfr:///terraform-aws-modules/vpc/aws?version=5.1.0"
}

inputs = {
  name = "vpc-lab-gratis"
  cidr = "10.0.0.0/16"

  # Solo una zona para no complicar el lab
  azs             = ["us-east-1a"]

  # Solo usamos subredes públicas para tener salida a internet sin NAT Gateway
  public_subnets  = ["10.0.1.0/24"]

  # IMPORTANTE: Desactivamos lo que cobra
  enable_nat_gateway = false
  enable_vpn_gateway = false

  # Esto ayuda a que las instancias se vean entre sí más fácil
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Environment = "dev"
    Project     = "InfraPlatformLab"
  }
}
