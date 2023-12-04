terraform {
  // source = "git::https://github.com/gruntlab/terraform-dynamodb-api.git//modules/http-api"
  source = "../../../modules/http-api"
   extra_arguments "custom_vars" {
    commands = [
      "apply",
      "plan",
      "import",
      "push",
      "destroy",
      "refresh"
    ]
    arguments = [
      "-var-file=nonprod.terraform.tfvars"
    ]
  }
}

locals {
  backend = jsondecode(read_tfvars_file("nonprod.backend.tfvars"))
}
remote_state {
  backend = "s3"
  config = {    
    bucket         = get_env("STATE_BUCKET", "${local.backend.bucket}")
    key            = "$(local.backend.workspace)/${basename(get_terragrunt_dir())}/terraform.tfstate"
    region         = get_env("REGION", "${local.backend.region}")
    encrypt        = true
    dynamodb_table = "${basename(get_terragrunt_dir())}-lock"
  }
}



