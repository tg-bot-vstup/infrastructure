terraform {
  source = "../../../modules/rds"
}

include {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../vpc"
}

inputs = {
  vpc_id = dependency.vpc.outputs.vpc_id
  subnets = dependency.vpc.outputs.private_subnets
}