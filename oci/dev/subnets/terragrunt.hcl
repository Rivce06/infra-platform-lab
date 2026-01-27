include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "envcommon" {
  path   = "${get_terragrunt_dir()}/../../../_envcommon/subnet-oci.hcl"
  expose = true
}