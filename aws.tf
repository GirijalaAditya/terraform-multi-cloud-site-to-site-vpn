resource "aws_vpc" "vpc" {
  cidr_block           = "192.168.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    "Name" = "my-vpc"
  }
}

resource "aws_subnet" "public-subnet" {
  cidr_block        = "192.168.1.0/24"
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "us-east-1a"
  tags = {
    Name = "Public-Subnet"
  }
}

resource "aws_subnet" "private-subnet" {
  cidr_block        = "192.168.10.0/24"
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "us-east-1b"
  tags = {
    Name = "Private-Subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "igw"
  }
}

resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "Public-Route-Table"
  }
}

resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "Private-Route-Table"
  }
}

resource "aws_route" "public-internet-gw-route" {
  route_table_id         = aws_route_table.public-route-table.id
  gateway_id             = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "public-route-table-1-association" {
  route_table_id = aws_route_table.public-route-table.id
  subnet_id      = aws_subnet.public-subnet.id
}

resource "aws_route_table_association" "private-route-table-2-association" {
  route_table_id = aws_route_table.private-route-table.id
  subnet_id      = aws_subnet.private-subnet.id
}

resource "aws_eip" "elastic-ip-for-nat-gw" {
  domain                    = "vpc"
  associate_with_private_ip = "10.0.0.5"
  tags = {
    Name = "my-eip"
  }
}

resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.elastic-ip-for-nat-gw.id
  subnet_id     = aws_subnet.public-subnet.id
  tags = {
    Name = "my-ngw"
  }
  depends_on = [aws_eip.elastic-ip-for-nat-gw]
}

resource "aws_route" "nat-gw-route" {
  route_table_id         = aws_route_table.private-route-table.id
  nat_gateway_id         = aws_nat_gateway.nat-gw.id
  destination_cidr_block = "0.0.0.0/0"
}

# data "azurerm_public_ip" "azure_public_ip_1" {
#   name                = "${azurerm_virtual_network_gateway.azure_vng.name}_public_ip_1"
#   resource_group_name = data.azurerm_resource_group.azure_rg.name
# }

# data "azurerm_public_ip" "azure_public_ip_2" {
#   name                = "${azurerm_virtual_network_gateway.azure_vng.name}_public_ip_2"
#   resource_group_name = data.azurerm_resource_group.azure_rg.name
# }

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

resource "aws_vpn_gateway" "vpn_gw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "vgn-gw"
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

resource "aws_route" "aws_azure_route" {
  route_table_id         = aws_route_table.private-route-table.id
  destination_cidr_block = azurerm_virtual_network.azure_vnet.address_space[0]
  gateway_id             = aws_vpn_gateway.vpn_gw.id
  depends_on             = [aws_route_table.private-route-table]
}