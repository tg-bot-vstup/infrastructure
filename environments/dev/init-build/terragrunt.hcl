terraform {
  source = "../../../modules/init-build"
}

include {
  path = find_in_parent_folders()
}

dependency "codebuild" {
  config_path = "../codebuild"
}

inputs = {
    codebuild_project_name = dependency.codebuild.outputs.codebuild_project_name
}