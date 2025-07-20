output "iam_instance_profile" {
  value = aws_iam_role.ec2_cloudwatch_role.name
}