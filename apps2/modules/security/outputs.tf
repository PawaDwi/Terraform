output "aws_db_subnet_group_name" {
  value = aws_db_subnet_group.example.name
}

output "aws_security_group_id" {
  value = aws_security_group.example.id
}

output "aws_subnet_id" {
  value = aws_subnet.subnet1.id
}
