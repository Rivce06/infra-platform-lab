include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "tfr:///oracle-terraform-modules/compute-instance/oci//modules/instance?version=1.0.6"
}

inputs = {
  compartment_id = local.compartment_id
  availability_domain = "kIdk:US-ASHBURN-AD-1"

  shape = "VM.Standard.A1.Flex"
  shape_config = {
    ocpus         = 1
    memory_in_gbs = 6
  }

  source_details = {
    source_type = "image"
    image_id    = local.oracle_linux_arm_image
  }

  subnet_id = dependency.vcn.outputs.private_subnet_id

  assign_public_ip = false

  metadata = {
    user_data = base64encode(file("${get_terragrunt_dir()}/user_data.sh"))
  }
}

dependency "vcn" {
  config_path = "../vcn"
}