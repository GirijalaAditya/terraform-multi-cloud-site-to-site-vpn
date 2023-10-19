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
  name                            = "azurevm"
  resource_group_name             = data.azurerm_resource_group.azure_rg.name
  location                        = data.azurerm_resource_group.azure_rg.location
  size                            = "Standard_D2s_v3"
  disable_password_authentication = false
  admin_username                  = "azureuser"
  admin_password                  = var.azure_vm_password
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
  name                = "azure-vm-nsg"
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
}
