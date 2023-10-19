output "azurevm_public_ip" {
  value = azurerm_linux_virtual_machine.azure_vm.public_ip_address
}

output "azurevm_private_ip" {
  value = azurerm_linux_virtual_machine.azure_vm.private_ip_address
}

output "aws_ec2_private_ip" {
  value = aws_instance.my-ec2-vm.private_ip
}