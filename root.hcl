locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl", "empty.hcl"), { locals = {} })
  tenancy_vars = read_terragrunt_config(find_in_parent_folders("tenancy.hcl", "empty.hcl"), { locals = {} })
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl", "empty.hcl"), { locals = {} })


  cloud = contains(split("/", get_terragrunt_dir()), "aws") ? "aws" : "oci"
  region = local.cloud == "oci" ? 
    try(local.tenancy_vars.locals.region, local.env_vars.locals.oci_region, "us-ashburn-1") : 
    try(local.env_vars.locals.aws_region, "us-east-1")

  env = try(local.env_vars.locals.environment, "dev")

  # --- PROVIDER ---
  aws_provider = <<-EOF
    provider "aws" {
      region = "${local.region}"
    }
  EOF

  oci_provider = <<-EOT
    provider "oci" {
      region = "${local.region}"
    }
  EOT
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = local.cloud == "aws" ? local.aws_provider : local.oci_provider
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