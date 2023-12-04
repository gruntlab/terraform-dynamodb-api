
bucket         = "octolab-nonprod-tfstate-20231106142704772600000001"
key            = "statefiles/serverless/terraform.tfstate"
dynamodb_table = "TerraformStatelock"
region         = "us-east-1"
encrypt        = true

