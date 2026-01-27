terraform {
  source = "tfr:///oracle-terraform-modules/vcn/oci?version=3.6.0"
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

inputs = {
  compartment_id = local.env_vars.locals.compartment_ocid

  label_prefix   = local.env_vars.locals.environment
  vcn_name       = "vcn-k3s-lab"
  vcn_dns_label  = "k3slab"

  vcn_cidrs = ["10.0.0.0/16"]

  create_internet_gateway = true
  lockdown_default_seclist = false
}
