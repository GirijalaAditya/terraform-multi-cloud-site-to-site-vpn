resource "azurerm_virtual_network" "azure_vnet" {
  name                = "my-vnet"
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
  allocation_method   = "Dynamic"
}

resource "azurerm_public_ip" "azure_pip_2" {
  name                = "pip-2"
  resource_group_name = data.azurerm_resource_group.azure_rg.name
  location            = data.azurerm_resource_group.azure_rg.location
  allocation_method   = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "azure_vng" {
  name                = "my-vng"
  location            = data.azurerm_resource_group.azure_rg.location
  resource_group_name = data.azurerm_resource_group.azure_rg.name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = true
  enable_bgp    = false
  sku           = "VpnGw1"

  ip_configuration {
    name                          = "vnetGatewayConfig1"
    public_ip_address_id          = azurerm_public_ip.azure_pip_1.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.azure_gw_sub.id
  }

  ip_configuration {
    name                          = "vnetGatewayConfig2"
    public_ip_address_id          = azurerm_public_ip.azure_pip_2.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.azure_gw_sub.id
  }
}

resource "azurerm_local_network_gateway" "lngw1_t1" {
  name                = "lngw1_t1"
  resource_group_name = data.azurerm_resource_group.azure_rg.name
  location            = data.azurerm_resource_group.azure_rg.location
  gateway_address     = aws_vpn_connection.vpn_cn1.tunnel1_address
  address_space       = [aws_vpc.vpc.cidr_block]
}

resource "azurerm_virtual_network_gateway_connection" "lngw1_t1_conn" {
  name                = "lngw1_t1_conn"
  location            = data.azurerm_resource_group.azure_rg.location
  resource_group_name = data.azurerm_resource_group.azure_rg.name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.azure_vng.id
  local_network_gateway_id   = azurerm_local_network_gateway.lngw1_t1.id

  shared_key = aws_vpn_connection.vpn_cn1.tunnel1_preshared_key
}

resource "azurerm_local_network_gateway" "lngw1_t2" {
  name                = "lngw1_t2"
  resource_group_name = data.azurerm_resource_group.azure_rg.name
  location            = data.azurerm_resource_group.azure_rg.location
  gateway_address     = aws_vpn_connection.vpn_cn1.tunnel2_address
  address_space       = [aws_vpc.vpc.cidr_block]
}

resource "azurerm_virtual_network_gateway_connection" "lngw1_t2_conn" {
  name                = "lngw1_t2_conn"
  location            = data.azurerm_resource_group.azure_rg.location
  resource_group_name = data.azurerm_resource_group.azure_rg.name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.azure_vng.id
  local_network_gateway_id   = azurerm_local_network_gateway.lngw1_t2.id

  shared_key = aws_vpn_connection.vpn_cn1.tunnel2_preshared_key
}

resource "azurerm_local_network_gateway" "lngw2_t1" {
  name                = "lngw2_t1"
  resource_group_name = data.azurerm_resource_group.azure_rg.name
  location            = data.azurerm_resource_group.azure_rg.location
  gateway_address     = aws_vpn_connection.vpn_cn2.tunnel1_address
  address_space       = [aws_vpc.vpc.cidr_block]
}

resource "azurerm_virtual_network_gateway_connection" "lngw2_t1_conn" {
  name                = "lngw2_t1_conn"
  location            = data.azurerm_resource_group.azure_rg.location
  resource_group_name = data.azurerm_resource_group.azure_rg.name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.azure_vng.id
  local_network_gateway_id   = azurerm_local_network_gateway.lngw2_t1.id

  shared_key = aws_vpn_connection.vpn_cn2.tunnel1_preshared_key
}

resource "azurerm_local_network_gateway" "lngw2_t2" {
  name                = "lngw2_t2"
  resource_group_name = data.azurerm_resource_group.azure_rg.name
  location            = data.azurerm_resource_group.azure_rg.location
  gateway_address     = aws_vpn_connection.vpn_cn2.tunnel2_address
  address_space       = [aws_vpc.vpc.cidr_block]
}

resource "azurerm_virtual_network_gateway_connection" "lngw2_t2_conn" {
  name                = "lngw2_t2_conn"
  location            = data.azurerm_resource_group.azure_rg.location
  resource_group_name = data.azurerm_resource_group.azure_rg.name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.azure_vng.id
  local_network_gateway_id   = azurerm_local_network_gateway.lngw2_t2.id

  shared_key = aws_vpn_connection.vpn_cn2.tunnel2_preshared_key
}