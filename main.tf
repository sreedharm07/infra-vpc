resource "aws_vpc" "main" {
  cidr_block = var.cidr
}


module "subnets" {
  source     = "./module"
  for_each = var.subnets

  subnets    = each.value
  vpc_id     = aws_vpc.main.id
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw"
  }
}

resource "aws_route" "igw" {
  for_each = lookup(lookup(module.subnets, "public", null), "route_table_ids", null)

  route_table_id         = each.value["id"]
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_eip" "lb" {
  count  = length(local.public_subnet_ids)
  domain = "vpc"
}

resource "aws_nat_gateway" "ngw" {
  count      = length(local.public_subnet_ids)

  allocation_id = element(aws_eip.lb.*.id, count.index )
  subnet_id = element(local.public_subnet_ids, count.index )

  tags = {
    Name = "ngw"
  }
}

resource "aws_route" "ngw" {
  count = length(local.private_route_ids)

  route_table_id         = element(local.private_route_ids, count.index )
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.ngw.*.id, count.index )
}

resource "aws_vpc_peering_connection" "main" {
  peer_vpc_id = aws_vpc.main.id
  vpc_id      = var.default_vpcid
  auto_accept   = true

  tags = {
    Name = "vpc peering"
  }
}

resource "aws_route" "peering" {
  count = length(local.private_route_ids)

  route_table_id            = element(local.private_route_ids, count.index )
  destination_cidr_block    = var.default_cidr_block
  vpc_peering_connection_id = element(aws_vpc_peering_connection.main.*.id,count.index )
}