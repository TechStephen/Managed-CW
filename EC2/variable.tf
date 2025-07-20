variable "subnet_id" {
  description = "Subnet ID for the EC2 instances"
  type        = string
}

variable "instance_profile" {
  description = "IAM role for CloudWatch Agent"
  type        = string
}