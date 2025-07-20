resource "aws_instance" "main_ec2" {
    ami           = "ami-0150ccaf51ab55a51"  # Example AMI ID, replace with a valid one
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.app_sg.id]
    key_name      = aws_key_pair.my_kp.key_name
    subnet_id = var.subnet_id
    iam_instance_profile = var.instance_profile

    user_data = <<-EOF
        #!/bin/bash
        sudo yum update -y
        sudo yum install -g npm
        sudo yum install -g pm2@latest

        sudo yum install -y amazon-cloudwatch-agent
        sudo systemctl enable amazon-cloudwatch-agent
        sudo systemctl start amazon-cloudwatch-agent

        sudo amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c ssm:/AmazonCloudWatch-linux
    EOF

    tags = {
        Project = "EC2-CW"
        Name    = "MainEC2Instance"
    }
}  

# SSM Parameter store for CW Logs
resource "aws_ssm_parameter" "cw_log_param" {
  name  = "/AmazonCloudWatch-linux"
  type  = "String"
  value = file("${path.module}/cloudwatch-agent-config.json")
  overwrite = true
}

# Create elastic IP
resource "aws_eip" "main_eip" {
    instance = aws_instance.main_ec2.id
}

# Generate SSH key pair
resource "tls_private_key" "my_key" {
    algorithm = "RSA"
    rsa_bits  = 2048
}

# Extract private keys
resource "aws_key_pair" "my_kp" {
    key_name   = "my_key_pair"
    public_key = tls_private_key.my_key.public_key_openssh # Ensure this file exists
}

# Save key pair to local file
resource "local_file" "key_pair_file" {
    content  = tls_private_key.my_key.private_key_pem
    filename = "./my_key_pair.pem"
}

resource "aws_security_group" "app_sg" {
  vpc_id = var.vpc_id
  name = "app_sg"
  description = "Security group for EC2 instance"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


