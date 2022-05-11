# Archetype Terraform workspace for use with Terraform Cloud

## Summary

This repository describes the basic steps to create a `workspace` repository; a `workspace` repository is used within Terraform Cloud (and the vending machine) in order to provide the desired configuration for each workload/environment/region

Workspaces are created (or "vended") in a unique product of `workload * environment * region`. For example creating "one" workspace for the `consumption-api` workload might ultimately turn into:

* `consumption-api-dev-usw2`
* `consumption-api-test-usw2`
* `consumption-api-test-euc1`
* `consumption-api-prod-usw2`
* `consumption-api-prod-euc1`
* `consumption-api-prod-apse2`

This archetype is only suitable for repositories which are dedicated to Terraform configuration only (which we will refer to as "infrastructure workspaces"). There is another type of workspace which is for deploying application workloads (for example ECS tasks) but as these are integrated with code repositories there is no cloneable archetype repository for these.

## Getting started and creating the (empty) workspace

1. Clone this template repository (for example as `terraform-workspace-${workload}`)
2. Set the correct permissions:
      1. `cx-terraform-cloud` needs to be an `Admin` level user (to allow Terraform Cloud to be able to configure webhooks)
      2. Other teams and users can be added as required, with the appropriate permissions
2. Set up branch protections on `main`:
      1. Require a pull request before merging
      2. Require approvals: 1
      3. Dismiss stale PR approvals when new commits are pushed
      4. Require status checks to pass before merging
      5. Require branches to be up to date before merging
      6. Include administrators
3. Under `General`, enable the option "Automatically delete head branches"
2. Take a look at the `example.tf` file for some basic syntax examples then remove it
2. Ensure that all the appropriate branches are created for the [vending machine](https://github.com/CXEPI/terraform-workspace-vendingmachine/blob/main/workspaces.tf) environments
3. Branch the `terraform-workspace-vendingmachine` repository and add your workspaces to the `workspaces = {}` `local` in the [`workspaces.tf`](https://github.com/CXEPI/terraform-workspace-vendingmachine/blob/main/workspaces.tf) file
4. Submit a PR with `CXEPI/sg1-admin` listed for review
5. Once merged, Terraform Cloud workspaces will be created per-region, per-environment for your desired workspaces 

## Populating the workspace (aka deploying your infrastructure)

A Terraform Cloud workspace is the "thing" that instantiates Terraform `modules`. A module creates one or more resources, and when it creates more then one resource it may manage relationships between them. As an example of what a module might do; consider a basic AWS application that would be hosted on EC2 instances, and the relationships between them:

* EC2 instances require subnets
* EC2 instances require routing (for example, an Internet Gateway or NAT Gateway)
* Gateways also require subnets
* Subnets require a VPC
* and so on

Your workspace could create all these resources individually, but "the Terraform way" is to bundle VPC/subnets/routing into a `module` and for you (as a team member populating your workspace) to simply instantiate that module and pass in appropriate arguments. This means that you don't need to consider all of these relationships for yourself and define them for every VPC you create, you simply need to call the `module` multiple times and the heavy lifting is largely done for you. This means the results will be more consistent (there's no way to accidentally leave a relationship out) and simpler (because these relationships are managed in the module, and some of the parameters may already be defined for you so you can pass in a smaller set of variables than you would normally need).

There is documentation on the Terraform website describing the process of using modules [here](https://www.terraform.io/language/modules#modules). The term "root module" is broadly equivalent to the term "workspace"; it's the thing that calls the other (child) modules.

Because these are equivalent and the workspace is itself a module, some assumptions are valid for both modules and workspaces:

* A workspace can take variable outputs from one module, and use them in an input to another module
* A workspace can use a `local` in order to manipulate an incoming `var`
* A workspace can declare outputs; as the root module has no caller these are passed out to become visible in the Terraform Cloud UI (unless they are marked as "sensitive")

However there are also some differences. `*.tfvars` files become valid within an SG1 workspace Git repository, with some conditions:
* Only the "correct" variable file will be read to match the region and environment on a workspace
  * `sample-workload-dev-usw2` would read from `dev.tfvars`, followed by `dev-us-west-2.tfvars` **and no others**
* `*.auto.tfvars` are still listed in `.gitignore` and **must not** be committed as this could cause variables to used in the wrong regions

## Important notes

* When it is vended by the vending machine, your Terraform Cloud workspace will have some pre-defined variables, which you can consume in your workspace using a `variable` block as shown in the example Terraform files:
  * `env` (`dev`, `test`, `stage`, `perf`, `prod`, etc)
  * `region` (`us-west-2`, `eu-central-1`, etc)
  * `short_region` (`usw2`, `euc1`, etc)
    * This variable **must** be used where you need to reduce characters, to make sure shortened region names are consistent across **all** environments/regions/workloads
* The workspace module _should not_ create `resource` items, it _should_ only create instances of `module` items
* The workspace _should_ only refer to `module` items from the [Private Module Registry](https://app.terraform.io/app/cxtfcloud/registry/private/modules)
  * (external vendors are currently under evaluation, but none are agreed/approved as yet)

## Further reading

* Module documentation - https://www.terraform.io/language/modules
* Module training - https://learn.hashicorp.com/collections/terraform/modules

## Automatically-generated documentation

This Markdown file contains some HTML comments marking the beginning/end of a documentation `pre-commit` hook, if `pre-commit` is enabled on this repository and these HTML comments are retained, then on every commit this `README.md` will be updated to contain the correct modules/inputs/outputs for your workspace repository.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_example_module"></a> [example\_module](#module\_example\_module) | app.terraform.io/cxtfcloud/vpc/aws | 1.0.5 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_env"></a> [env](#input\_env) | This is populated in every vending machine workspace | `string` | n/a | yes |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | This is not automatically populated in the workspace but could be pulled from a .tfvars file | `list(string)` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | This is populated in every vending machine workspace | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_example_output"></a> [example\_output](#output\_example\_output) | outputs the ARN of the created VPC, once it is created successfully |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
