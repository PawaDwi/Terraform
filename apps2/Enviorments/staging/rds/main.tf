terraform {
  backend "local" {
    path = "./state.tfstate"
  }
}

module "rds" {
  source      = "../../../modules/rds/"
  environment = var.environment
}


output "aws_db_password" {
  value     = module.rds.aws_db_password
  sensitive = true
}

output "database_endpoint" {
  value = module.rds.database_endpoint
}

output "rds_username" {
  value = module.rds.rds_username
}
