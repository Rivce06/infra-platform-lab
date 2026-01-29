include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "tfr:///terraform-aws-modules/ec2-instance/aws?version=5.5.0"
}

dependency "vpc" { config_path = "../vpc" }
dependency "sg"  { config_path = "../security-groups" }
dependency "iam" { config_path = "../iam-roles" }
# Esta es la dependencia que leerá el Master de OCI cuando haya capacidad
dependency "oci_master" { 
  config_path = "../../../oci/dev/k3s-masters" 
  skip_outputs = true # Temporalmente true mientras OCI está Out of Capacity
}

inputs = {
  # Sacamos los valores de los locals del root/env
  name          = "k3s-aws-agent-${include.root.locals.env}"
  instance_type = include.root.locals.env_vars.locals.instance_type
  ami           = include.root.locals.env_vars.locals.ami_id

  subnet_id              = dependency.vpc.outputs.public_subnets[0]
  vpc_security_group_ids = [dependency.sg.outputs.security_group_id]
  iam_instance_profile   = dependency.iam.outputs.iam_instance_profile_name
  
  associate_public_ip_address = true

  user_data = file("${get_terragrunt_dir()}/user_data.sh")

  tags = {
    Role = "k3s-agent"
  }
}