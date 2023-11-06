terraform {
  source = "git::https://github.com/gruntlab/terraform-dynamodb-api.git//modules/http-api"

   extra_arguments "custom_vars" {
    commands = [
      "apply",
      "plan",
      "import",
      "push",
      "refresh"
    ]

    # With the get_terragrunt_dir() function, you can use relative paths!
    arguments = [
      "-var-file=nonprod.terraform.tfvars"
    ]
  }


}

remote_state {
  backend = "s3"
  config = {    
    bucket         = "octolab-nonprod-tfstate-20231106142704772600000001"
    key            = "statefiles/serverless/${basename(get_terragrunt_dir())}/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "${basename(get_terragrunt_dir())}-lock"
  }
}



