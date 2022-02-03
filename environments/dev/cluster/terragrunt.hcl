terraform {
  source = "../../../modules/cluster"
}

include {
  path = find_in_parent_folders()
}

dependency "ecr" {
  config_path = "../ecr"
}

dependency "vpc" {
  config_path = "../vpc"
}

locals {
  secrets = read_terragrunt_config(find_in_parent_folders("secrets.hcl"), {inputs = {}})
}

inputs = merge(
  local.secrets.inputs,
  {
    ecr_repo_url = dependency.ecr.outputs.ecr_repo_url
    vpc_id = dependency.vpc.outputs.vpc_id
    subnets = dependency.vpc.outputs.private_subnets
  }
)