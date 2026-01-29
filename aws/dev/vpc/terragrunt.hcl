include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "tfr:///terraform-aws-modules/vpc/aws?version=5.1.0"
}

inputs = {
  name = "vpc-lab"
  cidr = "10.0.0.0/16"

  
  azs = ["${include.root.locals.aws_region}a"]

  public_subnets  = ["10.0.1.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Component = "network"
  }
}
