output "aws_ec2_private_ip" {
  value = aws_instance.my-ec2-vm.private_ip
}