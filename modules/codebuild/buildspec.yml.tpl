version: 0.2

env:
  variables:
    REPO_REGION: "${aws_region}"
    ENV: "${environment}"
    APP_NAME: "${app_name}"
    INFRA_REPO: "${infra_repo_url}"
    TERRAFORM_VERSION: "0.14.7"
    TERRAGRUNT_VERSION: "0.28.7"
    BOT_TOKEN_ARN: "${bot_token_arn}"
    DB_URL_ARN: "${db_url_arn}"
    
phases:
  pre_build:
    commands:
      - curl -sSL "https://releases.hashicorp.com/terraform/$${TERRAFORM_VERSION}/terraform_$${TERRAFORM_VERSION}_linux_amd64.zip" -o terraform.zip
      - unzip terraform.zip -d /usr/local/bin && chmod +x /usr/local/bin/terraform
      - curl -sSL https://github.com/gruntwork-io/terragrunt/releases/download/v$${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 -o terragrunt
      - mv terragrunt /usr/local/bin/ && chmod +x /usr/local/bin/terragrunt
      - export REGISTRY_ID=`aws sts get-caller-identity --output text | awk '{print $1}'`
      - export ECR_REPO_URL="$${REGISTRY_ID}.dkr.ecr.$${REPO_REGION}.amazonaws.com/$${APP_NAME}-$${ENV}"
      - pip install jq

  build:
    commands:
      - echo "Building and pushing docker images to the cloud..."
      - cd "$${CODEBUILD_SRC_DIR}/"
      - export TAG="$${CODEBUILD_RESOLVED_SOURCE_VERSION}-$${ENV}"
      - echo "Building version $${TAG}"
      - echo "Logging in to ECR in Docker"
      - aws ecr get-login-password --region "$REPO_REGION" | docker login --username AWS --password-stdin "$REGISTRY_ID.dkr.ecr.$REPO_REGION.amazonaws.com"
      - echo "Building Docker container..."
      - docker build -t "$ECR_REPO_URL" -f ./Dockerfile .
      - echo "Pushing..."
      - docker push "$ECR_REPO_URL"
      - docker tag "$ECR_REPO_URL" "$ECR_REPO_URL:$TAG"
      - docker push "$ECR_REPO_URL:$TAG"
      - echo "Applying Terraform cluster config"
      - cd "/tmp/" 
      - git clone "$INFRA_REPO" infra
      - cd infra/environments/$${ENV}/
      - terragrunt run-all plan --terragrunt-include-dir "cluster" -var="image_tag=$${TAG}" -var="bot_token_arn=$${BOT_TOKEN_ARN}" -var="db_url_arn=$${DB_URL_ARN}" -no-color -input=false -out plan.out
      - terragrunt run-all apply -auto-approve -no-color -input=false plan.out