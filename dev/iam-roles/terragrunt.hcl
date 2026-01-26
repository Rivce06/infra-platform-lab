include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "tfr:///terraform-aws-modules/iam/aws//modules/iam-assumable-role?version=5.30.0"
}

inputs = {
  create_role = true
  role_name   = "k3s-ssm-role"
  
  trusted_role_services = ["ec2.amazonaws.com"]
  
  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  ]
  
  # Esto es lo que permite que la EC2 use el rol
  create_instance_profile = true
}