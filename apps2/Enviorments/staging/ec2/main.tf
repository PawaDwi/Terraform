#Creating terraform tfstate
terraform {
  backend "local" {
    path = "./state.tfstate"
  }
}

module "ec2" {
  source      = "../../../modules/ec2/"
  environment = var.environment                       
}

output "aws_instance_id" {
  value     = module.ec2.aws_instance_id
  sensitive = true
}

output "public_ip" {
  value = module.ec2.public_ip
}

output "tls_private_key" {
  value = module.ec2.tls_private_key
   sensitive = true
}