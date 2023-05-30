#Creating terraform tfstate
terraform {
  backend "local" {
    path = "./state.tfstate"
  }
}


module "elastic_ip" {
  source      = "../../../modules/eip"
}

output "elastic_ip" {
  value = module.elastic_ip.elastic_ip
}
