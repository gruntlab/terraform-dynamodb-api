# Input variable definitions

variable "aws_region" {
  description = "AWS region for all resources."
  type        = string
  default     = "us-east-1"
}

variable "product" {
  type        = string
  description = ""
}

variable "table_name" {
  type        = string
  description = "ID of the security group for the CTS load balancer"
}

variable "environment" {
  type        = string
  description = "Environment"
}





