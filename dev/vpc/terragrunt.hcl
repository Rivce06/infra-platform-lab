include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "tfr:///terraform-aws-modules/vpc/aws?version=5.1.0"
}

inputs = {
  name = "vpc-dev"
  cidr = "10.0.0.0/16"
}
