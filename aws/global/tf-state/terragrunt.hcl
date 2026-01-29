include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

# Usamos el módulo oficial de AWS para S3
terraform {
  source = "tfr:///terraform-aws-modules/s3-bucket/aws?version=4.1.2"
}

inputs = {
  bucket = include.root.remote_state.config.bucket
  
  force_destroy           = false
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  versioning = {
    enabled = true
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name        = "Terraform State Storage"
    Component   = "Backend"
  }
}