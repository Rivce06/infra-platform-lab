include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  home_dir     = get_env("HOME", "/home/opc")
  ssh_key_path = "${local.home_dir}/.ssh/id_rsa.pub"
}

terraform {
  source = "tfr:///oracle-terraform-modules/compute-instance/oci?version=2.4.1"
}

dependency "subnets" {
  config_path = "../subnets"
}

inputs = {
  compartment_ocid      = local.env_vars.locals.compartment_ocid
  availability_domain   = "grlD:US-ASHBURN-AD-2"
  instance_display_name = "github-runner-dev"

  shape        = "VM.Standard.A1.Flex"
  shape_config = { ocpus = 1, memory_in_gbs = 6 }

  source_id    = "ocid1.image.oc1.iad.aaaaaaaa3ottpdtaqgmxosixupd6nxqzrl2hlb4x3lqjniasm7agykicdwka"
  source_ocid  = "ocid1.image.oc1.iad.aaaaaaaa3ottpdtaqgmxosixupd6nxqzrl2hlb4x3lqjniasm7agykicdwka"

  subnet_ocids     = [dependency.subnets.outputs.subnet_id["public"]]
  assign_public_ip = true

  ssh_public_keys     = file(local.ssh_key_path)
  ssh_authorized_keys = null 

  metadata = {
    user_data = base64encode(file("${get_terragrunt_dir()}/user_data.sh"))
  }
}
