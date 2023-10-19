resource "azurerm_virtual_network" "azure_vnet" {
  name                = "azure-vnet"
  address_space       = ["10.0.0.0/16"]
  resource_group_name = data.azurerm_resource_group.azure_rg.name
  location            = data.azurerm_resource_group.azure_rg.location
}

resource "azurerm_subnet" "azure_sub" {
  name                 = "default"
  address_prefixes     = ["10.0.0.0/24"]
  resource_group_name  = data.azurerm_resource_group.azure_rg.name
  virtual_network_name = azurerm_virtual_network.azure_vnet.name
}

resource "azurerm_subnet" "azure_gw_sub" {
  name                 = "GatewaySubnet"
  address_prefixes     = ["10.0.10.0/24"]
  resource_group_name  = data.azurerm_resource_group.azure_rg.name
  virtual_network_name = azurerm_virtual_network.azure_vnet.name
}

resource "azurerm_public_ip" "azure_pip_1" {
  name                = "pip-1"
  resource_group_name = data.azurerm_resource_group.azure_rg.name
  location            = data.azurerm_resource_group.azure_rg.location
  allocation_method   = "Static"
}

resource "azurerm_public_ip" "azure_pip_2" {
  name                = "pip-2"
  resource_group_name = data.azurerm_resource_group.azure_rg.name
  location            = data.azurerm_resource_group.azure_rg.location
  allocation_method   = "Static"
}