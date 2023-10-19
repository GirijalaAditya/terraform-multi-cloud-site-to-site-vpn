resource "aws_vpn_gateway" "vpn_gw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "vgn-gw"
  }
}

resource "aws_customer_gateway" "cgw1" {
  bgp_asn    = 65000
  ip_address = azurerm_public_ip.azure_pip_1.ip_address
  type       = "ipsec.1"

  tags = {
    Name = "cgw1"
  }
}

resource "aws_customer_gateway" "cgw2" {
  bgp_asn    = 65000
  ip_address = azurerm_public_ip.azure_pip_2.ip_address
  type       = "ipsec.1"

  tags = {
    Name = "cgw2"
  }
}

resource "aws_vpn_connection" "vpn_cn1" {
  vpn_gateway_id      = aws_vpn_gateway.vpn_gw.id
  customer_gateway_id = aws_customer_gateway.cgw1.id
  type                = "ipsec.1"
  static_routes_only  = true
}

resource "aws_vpn_connection" "vpn_cn2" {
  vpn_gateway_id      = aws_vpn_gateway.vpn_gw.id
  customer_gateway_id = aws_customer_gateway.cgw2.id
  type                = "ipsec.1"
  static_routes_only  = true
}

resource "aws_vpn_connection_route" "vpn_cn_r1" {
  destination_cidr_block = azurerm_virtual_network.azure_vnet.address_space[0]
  vpn_connection_id      = aws_vpn_connection.vpn_cn1.id
}

resource "aws_vpn_connection_route" "vpn_cn_r2" {
  destination_cidr_block = azurerm_virtual_network.azure_vnet.address_space[0]
  vpn_connection_id      = aws_vpn_connection.vpn_cn2.id
}

resource "aws_route" "aws_azure_route_pub_sub" {
  route_table_id         = aws_route_table.public-route-table.id
  destination_cidr_block = azurerm_virtual_network.azure_vnet.address_space[0]
  gateway_id             = aws_vpn_gateway.vpn_gw.id
  depends_on             = [aws_route_table.public-route-table]
}

resource "aws_route" "aws_azure_route_pvt_sub" {
  route_table_id         = aws_route_table.private-route-table.id
  destination_cidr_block = azurerm_virtual_network.azure_vnet.address_space[0]
  gateway_id             = aws_vpn_gateway.vpn_gw.id
  depends_on             = [aws_route_table.private-route-table]
}