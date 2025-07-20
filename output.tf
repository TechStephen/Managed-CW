output "public_ip" {
  value = module.ec2.public_ip
}

output "instance_id" {
  value = module.ec2.instance_id
}

output "private_key" {
  value = module.ec2.private_key
  sensitive = true
}