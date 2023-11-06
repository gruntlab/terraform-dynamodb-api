# terraform-dynamodb-api

## init

terraform init

## Plan

terraform plan -var-file="nonprod.terraform.tfvars" -lock=false

## Apply

terraform apply -var-file="nonprod.terraform.tfvars" --auto-approve
