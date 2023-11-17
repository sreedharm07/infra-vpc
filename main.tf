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

resource "aws_route" "route" {
  for_each = lookup(lookup(module.subnets, "public", null), "route_table_ids", null)

  route_table_id         = each.value["id"]
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_eip" "lb" {
  for_each = lookup(lookup(module.subnets, "public", null), "route_table_ids", null)
  domain   = "vpc"
}

resource "aws_nat_gateway" "example" {
  for_each      = lookup(lookup(module.subnets, "public", null), "subnets", null)

  allocation_id = aws_eip.lb[each.value].id
  subnet_id = each.value["id"]

  tags = {
    Name = each.key
  }
}
