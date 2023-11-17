resource "aws_vpc" "main" {
  cidr_block = var.cidr
}


module "subnets" {
  source     = "./module"
  for_each   = var.subnets
  subnets    = each.value
  vpc_id     = aws_vpc.main.id
  cidr_block = each.value["cidr"]
  az= each.value["az"]
}