terraform {
  source = "../lambda-api-gateway"
}

include {
    path = "../terragrunt-include/terragrunt.hcl"
}

dependencies {
    paths = ["../dynamodb"]
}
