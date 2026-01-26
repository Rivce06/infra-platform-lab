!/bin/bash
dnf update -y

# Terraform
dnf install -y dnf-utils
dnf config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
dnf install -y terraform

# Terragrunt
curl -Lo /usr/local/bin/terragrunt \
  https://github.com/gruntwork-io/terragrunt/releases/download/v0.54.10/terragrunt_linux_arm64
chmod +x /usr/local/bin/terragrunt

# AWS CLI (para backend S3)
dnf install -y awscli

# Git
dnf install -y git