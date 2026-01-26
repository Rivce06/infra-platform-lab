locals {
  # 1. Cargamos el env.hcl con un fallback para que no sea null
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl", "empty.hcl"), { locals = {} })

  # 2. Extraemos valores con try() para evitar el error de "null value"
  env    = try(local.env_vars.locals.env, "root")
  region = try(local.env_vars.locals.aws_region, "us-east-1")
}

remote_state {
  backend = "s3"
  disable_init = true
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    # 3. Usamos una variable de entorno o un dummy si no hay AWS configurado
    # Esto evita que falle el check si no has hecho aws configure
    bucket         = "platform-lab-state-${get_env("AWS_ACCOUNT_ID", "local-dev")}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.region
    encrypt        = true
    dynamodb_table = "terraform-lock"
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
      Environment = "${local.env}"
      Owner       = "Rivce06"
      ManagedBy   = "Terragrunt"
    }
  }
}
EOF
}
