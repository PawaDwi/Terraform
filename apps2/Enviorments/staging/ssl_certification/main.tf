module "ssl_certificate" {
  source      = "../../../modules/ssl_certificate/"
  environment = var.environment                       
}