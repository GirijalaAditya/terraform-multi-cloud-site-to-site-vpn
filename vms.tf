resource "azurerm_public_ip" "azure_pip" {
  name                = "vm-pip"
  resource_group_name = data.azurerm_resource_group.azure_rg.name
  location            = data.azurerm_resource_group.azure_rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "azure_vmnic" {
  name                = "vmnic"
  location            = data.azurerm_resource_group.azure_rg.location
  resource_group_name = data.azurerm_resource_group.azure_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.azure_sub.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.azure_pip.id
  }
}

resource "azurerm_linux_virtual_machine" "azure_vm" {
  name                            = "myvm"
  resource_group_name             = data.azurerm_resource_group.azure_rg.name
  location                        = data.azurerm_resource_group.azure_rg.location
  size                            = "Standard_D2s_v3"
  disable_password_authentication = false
  admin_username                  = "aditya"
  admin_password                  = "Shivarama@2000"
  network_interface_ids = [
    azurerm_network_interface.azure_vmnic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

resource "azurerm_network_security_group" "az_nsg" {
  name                = "my-nsg"
  location            = data.azurerm_resource_group.azure_rg.location
  resource_group_name = data.azurerm_resource_group.azure_rg.name

  security_rule {
    name                       = "allow-all"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}


resource "azurerm_network_interface_security_group_association" "nic_nsg" {
  network_security_group_id = azurerm_network_security_group.az_nsg.id
  network_interface_id      = azurerm_network_interface.azure_vmnic.id
  depends_on                = [azurerm_linux_virtual_machine.azure_vm, azurerm_network_security_group.az_nsg]
}

resource "aws_security_group" "vpc-ssh" {
  name        = "vpc-ssh"
  vpc_id      = aws_vpc.vpc.id
  description = "VPC SSH"
  ingress {
    description = "Allow Port 22"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "Allow all IP and Ports outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "vpc-web" {
  name        = "vpc-web"
  description = "VPC Web"
  vpc_id = aws_vpc.vpc.id
  ingress {
    description = "Allow Port 80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow Port 443"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all IP and Ports outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "my-ec2-vm" {
  depends_on = [ aws_vpc.vpc ]
  ami                    = "ami-067d1e60475437da2"
  instance_type          = "t2.micro"
  key_name               = "terraform-key"
  subnet_id              = aws_subnet.private-subnet.id
  user_data              = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install httpd -y
    sudo systemctl enable httpd
    sudo systemctl start httpd
    echo "<h1>Simple WebApp using Terraform in us-east-1 Region</h1>" > /var/www/html/index.html
    EOF
  vpc_security_group_ids = [aws_security_group.vpc-ssh.id, aws_security_group.vpc-web.id]
  tags = {
    "Name" = "myec2vm"
  }
}