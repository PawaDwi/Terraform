

provider "aws" {
  region = "us-east-1"
}


module "mymodule" {
  source = "../../modules/apps/"
  # vpc_cidr = var.prodcidr
}
