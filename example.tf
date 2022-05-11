provider "aws" {
  region = var.region
}

variable "region" {
  type        = string
  description = "This is populated in every vending machine workspace"
}

variable "env" {
  type        = string
  description = "This is populated in every vending machine workspace"
}

variable "private_subnets" {
  type        = list(string)
  description = "This is not automatically populated in the workspace but could be pulled from a .tfvars file"
}

module "example_module" {
  /*
    This source/version combination pulls from
    https://app.terraform.io/app/cxtfcloud/registry/modules/private/cxtfcloud/vpc/aws/1.0.5

    This registry page then documents the required and optional variables
    https://app.terraform.io/app/cxtfcloud/registry/modules/private/cxtfcloud/vpc/aws/1.0.5?tab=inputs
  */

  source  = "app.terraform.io/cxtfcloud/vpc/aws"
  version = "1.0.5"
  # insert required variables here

  region          = var.region                                    // this variable is pre-populated in every vending machine workspace
  name            = "example VPC for ${var.env} in ${var.region}" // these two variables are pre-populated and can be inserted into strings
  private_subnets = var.private_subnets                           // this would be populated by a .tfvars file
  cidr            = "10.0.0.0/16"                                 // this input variable is hard-coded and not variable within the workspace
}

output "example_output" {
  value       = module.example_module.vpc_arn
  description = "outputs the ARN of the created VPC, once it is created successfully"
}
