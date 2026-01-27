# root.hcl
locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl", "empty.hcl"), { locals = {} })
  tenancy_vars = read_terragrunt_config(find_in_parent_folders("tenancy.hcl", "empty.hcl"), { locals = {} })
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl", "empty.hcl"), { locals = {} })
  oci_auth_method = get_env("OCI_AUTH", "security_token")

  env    = try(local.env_vars.locals.environment, "root")
  region = try(local.env_vars.locals.aws_region, "us-east-1")
  cloud  = contains(split("/", get_terragrunt_dir()), "aws") ? "aws" : "oci"

  # --- BLOQUES DE PROVEEDORES DEFINIDOS COMO STRINGS LIMPIOS ---
  aws_provider = <<-EOF
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

  oci_provider = <<-EOF
  provider "oci" {
   auth                = "${local.oci_auth_method == "instance_principal" ? "InstancePrincipal" : "SecurityToken"}"
   config_file_profile = "${local.oci_auth_method == "instance_principal" ? "" : "DEFAULT"}"
   tenancy_ocid        = "${local.tenancy_vars.locals.tenancy_ocid}"
   region              = "${local.tenancy_vars.locals.region}"
}
EOF
}

remote_state {
  backend = "local"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
   
    
    path = "terraform.tfstate"
    
    
  }
}

# La lógica de generación ahora es una simple referencia a variables locales
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = local.cloud == "aws" ? local.aws_provider : local.oci_provider
}