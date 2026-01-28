include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  source = "tfr:///oracle-terraform-modules/compute-instance/oci?version=2.4.1"
}

dependency "subnets" {
  config_path = "../subnets"
}

inputs = {
  compartment_ocid      = local.env_vars.locals.compartment_ocid
  availability_domain   = "grlD:US-ASHBURN-AD-1"
  instance_display_name = "github-runner-dev"

  shape = "VM.Standard.A1.Flex"
  shape_config = { ocpus = 1, memory_in_gbs = 6 }

  source_ocid           = "ocid1.image.oc1.iad.aaaaaaaaajanbyeo3gxw3ygutzp5ibsb66jtianbnlbomzn737qfzwugcnha"

  subnet_ocids          = [dependency.subnets.outputs.subnet_id["public"]]
  assign_public_ip      = true

  ssh_public_keys = [file("~/.ssh/id_rsa_runner.pub")]

  metadata = {
    user_data = base64encode(file("${get_terragrunt_dir()}/user_data.sh"))
  }
}
