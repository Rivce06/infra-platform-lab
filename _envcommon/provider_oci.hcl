generate "provider_oci" {
  path      = "provider_oci.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "oci" {
  auth = "InstancePrincipal"
  region = var.oci_region
}
EOF
}