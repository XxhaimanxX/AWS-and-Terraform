module "network" {
  source = "../modules/network"
  vpc_cidr_block = var.vpc_cidr_block
  aws_region = var.aws_region
  az_1 = var.az_1
  az_2 = var.az_2
  private_sub_cidr_block = var.private_sub_cidr_block
  private_sub2_cidr_block = var.private_sub2_cidr_block
  public_sub_cidr_block = var.public_sub_cidr_block
  public_sub2_cidr_block = var.public_sub2_cidr_block
}