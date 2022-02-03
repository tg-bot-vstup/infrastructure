resource "null_resource" "build" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "aws codebuild start-build --project-name $${PROJECT_NAME}"
    environment = {
      PROJECT_NAME = var.codebuild_project_name
    }
  }
}
