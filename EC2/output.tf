output "instance_id" {
  value = aws_instance.main_ec2.id
}

output "public_ip" {
  value = aws_eip.main_eip.public_ip
}

output "private_key" {
  value = tls_private_key.my_key.private_key_pem
}
