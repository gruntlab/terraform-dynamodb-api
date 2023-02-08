# terraform-dynamodb-api

## init

terraform init -backend-config="dev.backend.tfvars"

## Plan

terraform plan -var-file="dev.terraform.tfvars"

## Apply

terraform apply -var-file="dev.terraform.tfvars"
