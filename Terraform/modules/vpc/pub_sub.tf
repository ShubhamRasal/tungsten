# create public subnets
resource "aws_subnet" "public" {
  count                     =   null_resource.az_count.triggers.total
  vpc_id                    =   aws_vpc.vpc.id
  cidr_block                =   cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone         =   data.aws_availability_zones.az_list.names[count.index]   
  map_public_ip_on_launch   =   true

  tags = {
        Name = "${var.project_prefix}-pub_subnet-${count.index + 1}"
        Tier = "Public"
    }
}

# create route table for attaching public subnet 
resource "aws_route_table" "public_route_table" {
  vpc_id        =   aws_vpc.vpc.id

  route {
    cidr_block  =   "0.0.0.0/0"
    gateway_id  =   aws_internet_gateway.igw.id
  }  
  tags = {
      Name = "${var.project_prefix}-public-routing-table"
      }
}

# Attach route table to subnet
resource "aws_route_table_association" "public" {
  count          =  length(aws_subnet.public.*.id)  
  subnet_id      =  aws_subnet.public[count.index].id
  route_table_id =  aws_route_table.public_route_table.id
}


