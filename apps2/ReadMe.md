                                            STEPS TO SETUP TERRAFORM 
=================================================================================================================

==> install teraaform
==>  install aws cli and then use command aws configure to set aws key,secret key ,region,format type.

*Define your infrastructure resources:
========================================

Create a Terraform configuration file (e.g., main.tf) that defines your infrastructure resources. This file will contain Terraform code that describes the infrastructure components that you want to provision.

Initialize Terraform:
In the root directory of your project, initialize Terraform by running the following command in the terminal:

code ------>  terraform init

*format and validate the infrastructure:
======================================

using terraform fmt to format the .tf extension file and then use terraform validate to validate


*Plan and apply the infrastructure:
==================================
Create a shell script or Makefile that runs the terraform plan and terraform apply commands. The terraform plan command will show you what changes Terraform will make to your infrastructure, and the terraform apply command will apply those changes. For example:

code --->  terraform plan -var-file="vars.tfvars" -out=tfplan
terraform apply tfplan

*Destroy the infrastructure:
==================================
When you are finished with your infrastructure resources, use the terraform destroy command to destroy them. This will free up resources and ensure that you are not charged for resources that you are not using. For example:

code ---> terraform destroy
These are the general steps to implement Terraform in a NestJS project. However, please note that the specifics will vary depending on your project's requirements and infrastructure.

 
 folder structure
====================
+----------------------+
| reductech-streaky/   |
|                      |
| +------------------+ |
| | environments/    | |
| |                  | |
| | +--------------+ | |
| | | development/ | | |
| | |              | | |
| | | main.tf      | | |
| | | variables.tf | | |
| | +--------------+ | |
| |                  | |
| | +----------+     | |
| | | staging/ |     | |
| | |          |     | |
| | | main.tf  |     | |
| | | variables.tf | | |
| | +----------+     | |
| +------------------+ |
|                      |
| +--------------+     |
| | modules/app     |     |
| |              |     |
| | +--------+   |     |
| | |   |   |     |
| | |        |   |     |
| | | main.tf|   |     |
| | | variables.tf |   |
| | +--------+   |     |
+----------------------+
