terraform {
  source = "../../../modules/codebuild"
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

dependency "rds" {
  config_path = "../rds"
}

locals {
  secrets = read_terragrunt_config(find_in_parent_folders("secrets.hcl"), {inputs = {}})
}

inputs = merge(
  local.secrets.inputs,
  {
    vpc_id = dependency.vpc.outputs.vpc_id
    subnets = dependency.vpc.outputs.private_subnets
    db_url = dependency.rds.outputs.db_url
  }
)