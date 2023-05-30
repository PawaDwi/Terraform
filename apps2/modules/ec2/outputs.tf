output "aws_instance_id" {
  value = aws_instance.example.id
}

output "public_ip" {
  value = aws_instance.example.public_ip
}

output "tls_private_key" {
  value = tls_private_key.example.private_key_pem
}