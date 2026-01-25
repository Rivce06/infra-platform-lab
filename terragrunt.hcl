locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region   = local.env_vars.locals.aws_region
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket         = "platform-lab-state-${get_aws_account_id()}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.region
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.region}"
  default_tags {
    tags = {
      Project     = "InfraPlatformLab"
      Environment = "${local.env_vars.locals.env}"
      Owner       = "Rivce06"
      ManagedBy   = "Terragrunt"
    }
  }
}
EOF
}