# creatin the vpc
module "VPC" {
  source           = "../modules/vpc"
  region           = var.region
  project_name     = var.project_name
  vpc_cidr         = var.vpc_cidr
  pub_sub_1_a_cidr = var.pub_sub_1_a_cidr
  pub_sub_2_b_cidr = var.pub_sub_2_b_cidr
  pri_sub_3_a_cidr = var.pri_sub_3_a_cidr
  pri_sub_4_b_cidr = var.pri_sub_4_b_cidr
  pri_sub_5_a_cidr = var.pri_sub_5_a_cidr
  pri_sub_6_b_cidr = var.pri_sub_6_b_cidr
}

# creating NAT_NAT-GW
module "NAT-GW" {
  source         = "../modules/nat-gateway"
  pub_sub_1_a_id = module.VPC.pub_sub_1_a_id
  igw_id         = module.VPC.igw_id
  pub_sub_2_b_id = module.VPC.pub_sub_2_b_id
  vpc_id         = module.VPC.vpc_id
  pri_sub_3_a_id = module.VPC.pri_sub_3_a_id
  pri_sub_4_b_id = module.VPC.pri_sub_4_b_id
  Pri_sub_5_a_id = module.VPC.Pri_sub_5_a_id
  pri_sub_5_a_id = module.VPC.pri_sub_5_a_id
}

# create security Group
module "SG" {
  source = "../modules/SG"
  vpc_id = module.VPC.vpc_id
}

# creating Key for instaces
module "KEY" {
  source = "../modules/key"
}

# launching JUMP server or Bastion host 
module "SERVER" {
  source         = "../modules/ec2"
  jump_sg_id     = module.SG.jump_sg_id
  pub_sub_1_a_id = module.VPC.public_sub_1_a_id
  key_name       = module.KEY.key_name
}
# Creating Application Load balancer
module "ALB" {
  source         = "../modules/alb"
  project_name   = module.VPC.project_name
  alb_sg_id      = module.SG.alb_sg_id
  pub_sub_1_a_id = module.VPC.pub_sub_1_a_id
  pub_sub_2_b_id = module.VPC.pub_sub_2_b_id
  vpc_id         = module.VPC.vpc_id

  tags = {
    Name = "${var.project_name}-alb"
  }
}

# Crating Auto Scaling group
module "ASG" {
  source         = "../modules/asg"
  project_name   = module.vpc.project_name
  key_name       = module.key.key_name
  client_sg_id   = module.sg.client_sg_id
  pri_sub_3_a_id = module.VPC.pri_sub_3_a_id
  pri_sub_4_b_id = module.VPC.pri_sub_4_b_id
  tg_arn         = module.ALB.tg_arn

}

# create RDS instance
module "RDS" {
  source         = "../modules/rds"
  db_sg_id       = module.SG.db_sg_id
  pri_sub_5_a_id = module.VPC.pri_sub_5_a_id
  pri_sub_6_b_id = module.VPC.pri_sub_6_b_id
  db_username    = var.db_username
  db_password    = var.db_password
}

# create cloudfront distribution 
module "CLOUDFRONT" {
  source                  = "../modules/cloud-front"
  certificate_domain_name = var.certificate_domain_name
  alb_domain_name         = var.alb_domain_name
  additional_domain_name  = var.additional_domain_name
  project_name            = var.project_name
}

# add record in route 53 hosted zone

module "ROUTE53" {
  source                    = "../modules/route53"
  cloudfront_domain_name    = module.CLOUDFRONT.cloudfront_domain_name
  cloudfront_hosted_zone_id = module.CLOUDFRONT.cloudfront_hosted_zone_id
}
