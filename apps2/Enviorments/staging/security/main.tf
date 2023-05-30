terraform {
  backend "local" {
    path = "./state.tfstate"
  }
}

module "security" {
  source      = "../../../modules/security"
 
}

output "aws_db_subnet_group_name" {
  value = module.security.aws_db_subnet_group_name
}

output "aws_security_group_id" {
  value = module.security.aws_security_group_id
}

output "aws_subnet_id" {
  value = module.security.aws_subnet_id
}
