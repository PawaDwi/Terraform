#Creating terraform tfstate
terraform {
  backend "local" {
    path = "./state.tfstate"
  }
}

module "ec2" {
  source = "../../../modules/ec2/"
}
