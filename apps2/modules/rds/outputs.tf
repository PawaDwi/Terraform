output "aws_db_password" {
  value = aws_db_instance.example.password
  sensitive = true
}

output "database_endpoint" {
  value = aws_db_instance.example.endpoint
}


output "rds_username" {
  value = aws_db_instance.example.username
}