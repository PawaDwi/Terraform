data "terraform_remote_state" "security" {
  backend = "local"
  config = {
    path = "../../../Enviorments/${var.environment}/security/state.tfstate"
  }
}
resource "aws_db_instance" "example" {
  identifier              = "example-rds-instance"
  engine                  = "postgres"
  username                = "postgres"
  password                = "MarsRover#9899"
  engine_version          = "12.7"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  max_allocated_storage   = 100
  storage_type            = "gp2"
  storage_encrypted       = true
  backup_retention_period = 0
  publicly_accessible     = true
  skip_final_snapshot     = true
  vpc_security_group_ids  = [data.terraform_remote_state.security.outputs.aws_security_group_id]
  db_subnet_group_name    = data.terraform_remote_state.security.outputs.aws_db_subnet_group_name
  parameter_group_name    = "example-db-parameter-group"
  deletion_protection     = false

}
