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

inputs = {
  ecr_repo_url = dependency.ecr.outputs.ecr_repo_url
  vpc_id = dependency.vpc.outputs.vpc_id
  subnets = dependency.vpc.outputs.private_subnets
}