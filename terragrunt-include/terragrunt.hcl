
locals {
  project_name = "gruntlab"
  environment = "dev"
}

remote_state {
  backend = "s3"
  config = {    
    # fix terragrunt init errors "cannot unmarshal string into Go struct field"
    skip_bucket_root_access  = true
    skip_bucket_enforced_tls = true
    disable_bucket_update    = true
    
    bucket         = "gruntlabs"
    key            = "serverless/${basename(get_terragrunt_dir())}/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "gruntlabs-lock-table-serverless"

    s3_bucket_tags = {
      owner = "gruntlabs"
      name  = "gruntlabs state storage"
    }
    dynamodb_table_tags = {
      owner = "gruntlabs"
      name  = "gruntlabs lock table"
    }
  }
}

inputs = {
  custom_app = "${local.project_name}-${local.environment}"

}
