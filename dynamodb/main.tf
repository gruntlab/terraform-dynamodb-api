terraform {
  backend "s3" {
  }
}

provider "aws" {
  region     = var.aws_region
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.19.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.3.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2.0"
    }
  }
  
  required_version = "~> 1.0"
}

##########################
# RESOURCES
##########################

resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = "${var.table_name}"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "prefix"
  # range_key      = "id"

  # attribute {
  #   name = "id"
  #   type = "S"
  # }

  attribute {
    name = "prefix"
    type = "S"
  }


  #   global_secondary_index {
  #     name               = "ItemIndex"
  #     hash_key           = "prefix"
  #     # range_key          = "price"
  #     write_capacity     = 10
  #     read_capacity      = 10
  #     projection_type    = "INCLUDE"
  #     non_key_attributes = ["id"]
  # }


  tags = {
    Name        = "infrastructure-reputations"
    Environment = "development"
  }
}

