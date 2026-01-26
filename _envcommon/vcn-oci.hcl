terraform {
  # Usamos el módulo oficial de Oracle (VCN)
  source = "tfr:///oracle-terraform-modules/vcn/oci?version=3.6.0"
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

inputs = {
  # Usamos el compartimento que acabas de crear
  compartment_id = local.env_vars.locals.compartment_ocid
  
  label_prefix = local.env_vars.locals.environment
  vcn_name     = "vcn-k3s-lab"
  vcn_dns_label = "k3slab"
  
  # Rango de IPs de la red
  vcn_cidrs = ["10.0.0.0/16"]

  # Creamos una subred pública para el Master/Runner
  create_internet_gateway = true
  lockdown_default_seclist = false # Para empezar fácil, luego cerramos
}