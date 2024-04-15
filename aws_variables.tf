variable "cidr_block" {
  type        = string
  description = "AWS VPC CIDR Block"
}

variable "public_subnet_cidr_block" {
  type        = string
  description = "Public Subnet CIDR Block"
}

variable "private_subnet_cidr_block" {
  type        = string
  description = "Public Subnet CIDR Block"
}

variable "aws_ec2_ami_id" {
  type        = string
  description = "EC2 AMI ID"
}