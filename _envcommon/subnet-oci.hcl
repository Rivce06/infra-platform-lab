terraform {
  source = "tfr:///oracle-terraform-modules/vcn/oci//modules/subnet?version=3.6.0"
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

dependency "vcn" {
  config_path = "${get_repo_root()}/oci/dev/vcn"
}

inputs = {
  compartment_id = local.env_vars.locals.compartment_ocid

  vcn_id   = dependency.vcn.outputs.vcn_id
  vcn_cidr = dependency.vcn.outputs.vcn_all_attributes.cidr_block

  ig_route_id  = dependency.vcn.outputs.ig_route_id
  nat_route_id = null

  subnets = {
    public = {
      cidr_block        = "10.0.1.0/24"
      dns_label         = "public"
      public_ip_on_vnic = true

      route_table_id    = dependency.vcn.outputs.ig_route_id
      security_list_ids = [
        dependency.vcn.outputs.default_security_list_id
      ]
    }
  }
}
