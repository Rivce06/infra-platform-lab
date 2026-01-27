locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl", "empty.hcl"), { locals = {} })
  tenancy_vars = read_terragrunt_config(find_in_parent_folders("tenancy.hcl", "empty.hcl"), { locals = {} })
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl", "empty.hcl"), { locals = {} })

  cloud = contains(split("/", get_terragrunt_dir()), "aws") ? "aws" : "oci"

  aws_region = try(local.env_vars.locals.aws_region, "us-east-1")
  oci_region = try(
    local.env_vars.locals.oci_region,
    local.tenancy_vars.locals.region,
    "us-ashburn-1"
  )

  region = local.cloud == "aws" ? local.aws_region : local.oci_region
  env    = try(local.env_vars.locals.environment, "root")

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
      region = "${local.region}"
    }
  EOF
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
