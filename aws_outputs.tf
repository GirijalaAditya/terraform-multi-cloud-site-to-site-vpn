output "public_ec2_instance_ip" {
  value = aws_instance.public_ec2_instance.private_ip
}

output "private_ec2_instance_ip" {
  value = aws_instance.private_ec2_instance.private_ip
}