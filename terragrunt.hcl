locals {
  # Carga de variables con fallback
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl", "empty.hcl"), { locals = {} })
  tenancy_vars = read_terragrunt_config(find_in_parent_folders("tenancy.hcl", "empty.hcl"), { locals = {} })
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl", "empty.hcl"), { locals = {} })

  # Extracción de valores
  env    = try(local.env_vars.locals.environment, "root")
  region = try(local.env_vars.locals.aws_region, "us-east-1")
  
  # Identificar en qué nube estamos basado en la ruta de la carpeta
  cloud  = contains(split("/", get_terragrunt_dir()), "aws") ? "aws" : "oci"
}

remote_state {
  backend = "s3"
  disable_init = true
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    # Centralizamos el estado en AWS incluso para OCI
    bucket         = "platform-lab-state-${get_aws_account_id()}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}

# Generar el proveedor dinámicamente
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = local.cloud == "aws" ? <<EOF
provider "aws" {
  region = "${local.region}"
  default_tags {
    tags = {
      Project     = "InfraPlatformLab"
      Environment = "${local.env}"
      ManagedBy   = "Terragrunt"
    }
  }
}
EOF
: <<EOF
provider "oci" {
  tenancy_ocid = "${local.tenancy_vars.locals.tenancy_ocid}"
  user_ocid    = "${local.tenancy_vars.locals.user_ocid}"
  fingerprint  = "${local.tenancy_vars.locals.fingerprint}"
  private_key  = "${local.tenancy_vars.locals.private_key}"
  region       = "${local.env_vars.locals.oci_region}"
}
EOF
}