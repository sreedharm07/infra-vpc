resource "aws_subnet" "main" {
  for_each = var.subnets

  vpc_id     = var.vpc_id
  cidr_block = each.value["cidr"]
  availability_zone = each.value["az"]

  tags = merge(var.tags, {Name = "${var.env}-${each.key}-subnet"})
}

resource "aws_route_table" "main" {
  vpc_id   = var.vpc_id
  for_each = var.subnets
  tags     = merge(var.tags, {Name = "${var.env}-${each.key}-route"} )
}

resource "aws_route_table_association" "a" {
  for_each = var.subnets
  subnet_id      = aws_subnet.main[each.key].id
  route_table_id = aws_route_table.main[each.key].id
}

