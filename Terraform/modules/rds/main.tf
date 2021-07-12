# create database subnets
# for subnet cidr of private subnets
# get subnet's azs
# data "aws_subnet_ids" "private" {
#   vpc_id = var.vpc_id

#   tags = {
#     Tier = "Private"
#   }
# }

# locals {
#   private_subnet_ids =  tolist(data.aws_subnet_ids.private.ids)
# }


data "aws_subnet" "private" {
 count = length(var.aws_private_subnet_ids)
 id = element(var.aws_private_subnet_ids, count.index)

}

resource "aws_db_subnet_group" "rds_sg" {
  name       = "${var.project_prefix}_rds_private_sg"
  subnet_ids = var.aws_private_subnet_ids

  tags = {
      "Name" = "${var.project_prefix}-subnet-group"
  }
}



# create security group and allow all private subnet group
resource "aws_security_group" "rds_sg" {
  name   = "${var.project_prefix}_rds_sg"
  vpc_id = var.vpc_id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = data.aws_subnet.private[*].cidr_block
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = data.aws_subnet.private[*].cidr_block
  }
}

resource "aws_db_instance" "rds_instance" {
  allocated_storage    = 10
  engine               = var.rds.engine
  engine_version       = var.rds.engine_version
  instance_class       = var.rds.instance_class
  name                 = var.rds.name
  username             = var.rds_username
  password             = var.rds_password
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.rds_sg.name

  tags = {
      "Name" = "${var.project_prefix}-${var.rds.engine}"
  }
}
