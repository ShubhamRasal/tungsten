# 1. VPC
resource "aws_vpc" "vpc" {
   cidr_block = var.vpc_cidr
   enable_dns_hostnames = true
    tags = {
       Name = "${var.project_prefix}-vpc"
    }
}

# 2. Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id          =   aws_vpc.vpc.id
  depends_on = [
    aws_vpc.vpc
  ]
      tags = {
       Name = "${var.project_prefix}-igw"
    }
}

data "aws_availability_zones" "az_list" {
  state = "available"
}

resource "null_resource" "az_names" {
  triggers = {
                        # slice( list, startindex, endindex)              minimum between inputed az count and no. of az
    names = join(",", slice(data.aws_availability_zones.az_list.names, 0, min(var.max_az, length(data.aws_availability_zones.az_list.names))))
  }
}

resource "null_resource" "az_count" {
  triggers = {
    total = length(split(",", null_resource.az_names.triggers.names))
  }
}


