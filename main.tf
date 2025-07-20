terraform {
    required_providers {
        aws = {
        source  = "hashicorp/aws"
        version = "~> 3.0"
        }
    }
    
    required_version = ">= 0.12"
}

provider "aws" {
    region = "us-east-1"    
}

module "IAM" {
    source = "./IAM"    
}

module "vpc" {
  source = "./VPC"
}

module "ec2" {
    source = "./EC2"
    subnet_id = module.vpc.subnet_id
    instance_profile = module.IAM.iam_instance_profile

    depends_on = [ module.vpc, module.IAM ]
}

