include "root" {
  path = find_in_parent_folders()
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  source = "tfr:///oracle-terraform-modules/compute-instance/oci//modules/instance?version=1.0.6"
}

inputs = {
  compartment_id = local.env_vars.locals.compartment_ocid
  availability_domain = "grlD:US-ASHBURN-AD-1"
  
  shape = "VM.Standard.A1.Flex"
  shape_config = {
    ocpus         = 1
    memory_in_gbs = 6
  }

  source_details = {
    source_type = "image"
    source_id = "ocid1.image.oc1.iad.aaaaaaaaajanbyeo3gxw3ygutzp5ibsb66jtianbnlbomzn737qfzwugcnha" 
  }

  subnet_id = dependency.vcn.outputs.public_subnets["public"].id
  assign_public_ip = true 

  metadata = {
    user_data = base64encode(file("${get_terragrunt_dir()}/user_data.sh"))
  }
}

dependency "vcn" {
  config_path = "../vcn"
}
