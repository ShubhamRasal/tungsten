# create private subnets
resource "aws_subnet" "private" {
  count                     =   null_resource.az_count.triggers.total
  vpc_id                    =   aws_vpc.vpc.id
  cidr_block                =   cidrsubnet(var.vpc_cidr, 8, count.index + null_resource.az_count.triggers.total )  # create cidr block considering public subnet
  availability_zone         =   data.aws_availability_zones.az_list.names[count.index]   
  map_public_ip_on_launch   =   false

  tags = {
        Name = "${var.project_prefix}-pri_subnet-${count.index + 1}"
        Tier = "Private"
    }
}

# If you have resources in multiple Availability Zones and they share one NAT gateway, 
# and if the NAT gateway’s Availability Zone is down, resources in the other 
#Availability Zones lose internet access. To create an Availability Zone-independent 
#architecture, create a NAT gateway in each Availability Zone and configure your 
#routing to ensure that resources use the NAT gateway in the same Availability Zone.

# create elastic ip for nat gateway
resource "aws_eip" "nat" {
  count = null_resource.az_count.triggers.total
  vpc   = true
  tags = {
       Name = "${var.project_prefix}-nat"
    }
}

# create nat gateway in each public subnet [ azs]
resource "aws_nat_gateway" "nat" {
  count         = null_resource.az_count.triggers.total
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  depends_on = [aws_internet_gateway.igw, aws_eip.nat]
}

# create route table for attaching public subnet 
resource "aws_route_table" "private_route_table" {
  count         = null_resource.az_count.triggers.total
  vpc_id        =   aws_vpc.vpc.id

  route {
    cidr_block  =   "0.0.0.0/0"
    nat_gateway_id  =   aws_nat_gateway.nat[count.index].id
  }  
  tags = {
      Name = "${var.project_prefix}-private-routing-table"
      }
}

# Attach route table to subnet
resource "aws_route_table_association" "private" {
  count          =  length(aws_subnet.private.*.id)  
  subnet_id      =  element(aws_subnet.private.*.id, count.index)
  route_table_id =  element(aws_route_table.private_route_table.*.id, count.index)
}
