include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  source = "tfr:///oracle-terraform-modules/compute-instance/oci?version=2.0.2"
}

dependency "subnets" {
  config_path = "../subnets"
}

inputs = {
  compartment_id      = local.env_vars.locals.compartment_ocid
  availability_domain = "grlD:US-ASHBURN-AD-1"

shape = "VM.Standard.E2.1.Micro"
shape_config = {
  ocpus         = 1
  memory_in_gbs = 1
}

  source_details = {
    source_type = "image"
    source_id   = "ocid1.image.oc1.iad.aaaaaaaaajanbyeo3gxw3ygutzp5ibsb66jtianbnlbomzn737qfzwugcnha"
  }

  subnet_id        = dependency.subnets.outputs.subnet_id["public"]
  assign_public_ip = true

  metadata = {
    user_data = base64encode(
      file("${get_terragrunt_dir()}/user_data.sh")
    )
  }
}

