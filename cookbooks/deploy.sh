#!/bin/bash

REGION="us-east-1"
STACK_ID="91944189-a0fd-4bd7-8584-20149f3368fe"
REPO_NAME="teamcitycookbooks.zip"
RECIPE_NAME="chef-teamcity-windows::default"
S3_REPO_BUCKET="s3://opsworks-source-cookbooks/berks-packages/"

# configure() {
#     if $(grep --quiet region ~/.aws/config); then
#         REGION=$(grep region ~/.aws/config | awk '{print $3}')
#     else
#         read -p "Please enter the AWS region of the stack: " REGION
#     fi
#     
#     read -p "Please enter recipe to be executed: " RECIPE_NAME
#     read -p "Please enter name of repository file to be deployed: " REPO_NAME
#     echo "Using parameters:"
#     echo "   REGION = ${REGION}"
#     echo "   STACK_ID = ${STACK_ID}"
#     echo "   REPO_NAME = ${REPO_NAME}"
# }

deploy() {
    find . -maxdepth 1 -mindepth 1 -type d -exec find {} \; | zip -@ "${REPO_NAME}" && aws s3 cp "${REPO_NAME}" "${S3_REPO_BUCKET}"

    AWS_DEPLOYMENT_ID=$(aws opsworks --region "$REGION" create-deployment --stack-id "${STACK_ID}" --command "{\"Name\":\"update_custom_cookbooks\"}") || exit

    status="running"
    while [ "$status" != "successful" ]; do
        echo "Deployment is $status..."
        sleep 5
        status=$(aws opsworks --region "$REGION" describe-deployments --deployment-id "${AWS_DEPLOYMENT_ID}" --query 'Deployments[0].Status')
    done

    if [ "$status" == "successful" ]; then
        echo "Cookbooks updated, executing recipes"
        aws opsworks --region "$REGION" create-deployment --stack-id "${STACK_ID}" --command "{\"Name\":\"execute_recipes\", \"Args\":{\"recipes\":[\"${RECIPE_NAME}\"]}}"
    else
        echo "Update cookbooks not successful. Deployment details:"
        aws opsworks --region "$REGION" describe-deployments --deployment-id "$AWS_DEPLOYMENT_ID" --output json
    fi
}

# configure
deploy


