# Input variable definitions

variable "aws_region" {
  description = "AWS region for all resources."
  type        = string
  default     = "us-east-1"
}

variable "table_name" {
  type        = string
  description = "ID of the security group for the CTS load balancer"
}

variable "environment" {
  type        = string
  description = "Environment"
}

variable "project_label" {
  type        = string
  description = "Project Label"
}


# variable "workspace" {
#   type        = string
#   description = "Workspace"
# }

# variable "state_bucket" {
#   type        = string
#   description = "State Bucket Name"
# }





