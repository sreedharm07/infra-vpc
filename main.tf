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
  for_each = lookup(lookup(lookup(module.subnets, null),"public",null),"route_table_ids",null)

  route_table_id            = each.value["id"]
  destination_cidr_block    = "0.0.0.0/0"

}

output "subnets" {
  value = module.subnets
}