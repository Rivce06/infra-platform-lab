include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "tfr:///terraform-aws-modules/ec2-instance/aws?version=5.5.0"
}

dependency "vpc" { config_path = "../vpc" }
dependency "sg"  { config_path = "../security-groups" }
dependency "iam" { config_path = "../iam-roles" }

# Creamos 2 instancias: una para Master y otra para Worker
for_each = toset(["master", "worker"])

inputs = {
  name = "k3s-${each.key}"

  instance_type          = "t2.micro"
  ami                    = "ami-0532be01f26a3de55" # mazon Linux 2023 (kernel-6.1)
  subnet_id              = dependency.vpc.outputs.public_subnets[0]
  vpc_security_group_ids = [dependency.sg.outputs.security_group_id]
  iam_instance_profile   = dependency.iam.outputs.iam_instance_profile_name

  user_data = <<-EOF
              #!/bin/bash
              fallocate -l 2G /swapfile
              chmod 600 /swapfile
              mkswap /swapfile
              swapon /swapfile
              echo '/swapfile none swap sw 0 0' >> /etc/fstab

              # 2. Instalar K3s
              curl -sfL https://get.k3s.io | sh -
              EOF
}
