terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
    region = var.aws_region
    default_tags {
      tags ={
          Environment = var.env
          Author      = var.author
          Project     = var.project_name
     }
  }
}



module "vpc" {
  source = "./modules/vpc"
  aws_region = var.aws_region
  project_prefix = local.project_prefix
  max_az = var.max_az
}

module "ec2"{
  source                = "./modules/ec2"
  vpc_id                = module.vpc.vpc_id
  create_bastion        = true
  bastion               = var.bastion

  create_service_box    = true
  service_box           = var.service_box
  sg_service_rules      = var.sg_service_rules
  
  alb_target_groups     = var.alb_target_groups
  certificate_arn       = var.certificate_arn
  project_prefix        = local.project_prefix

  depends_on = [
    module.vpc
  ]
}


module "rds" {
  source                 = "./modules/rds"
  vpc_id                 =  module.vpc.vpc_id
  project_prefix         =  local.project_prefix
  rds                    =  var.rds
  rds_username           =  var.rds_username
  rds_password           =  var.rds_password
  aws_private_subnet_ids =  module.vpc.private_subnet_list
  depends_on = [
    module.vpc
  ]
}

module "s3" {
  source = "./modules/s3"
  bucket_name         = "one2n-demo-bucket"
  project_prefix      = local.project_prefix
}


resource "local_file" "bastion_pem" { 
  filename = "${path.root}/ssh_keys/${local.project_prefix}-bastion.pem"
  content = module.ec2.bastion_private_key
  file_permission = "0600"
}

resource "local_file" "service_pem" { 
  filename = "${path.root}/ssh_keys/${local.project_prefix}-service.pem"
  content = module.ec2.service_private_key
  file_permission = "0600"

}