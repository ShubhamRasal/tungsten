resource "aws_security_group" "sg_service" {
  name        = "sg_service"
  description = "Allow service box inbound traffic"
  vpc_id      = var.vpc_id
  
  dynamic "ingress" {
     for_each = [ for rule in var.sg_service_rules:{
         desc   = rule.description
         port   = rule.ingress_port
         protocol = rule.protocol
         cidr_blocks = rule.cidr_blocks
         ipv6_cidr_blocks = rule.ipv6_cidr_blocks
     }]
      content  {
        description      = ingress.value.desc
        from_port        = ingress.value.port
        to_port          = ingress.value.port
        protocol         = ingress.value.protocol
        cidr_blocks      = ingress.value.cidr_blocks
        ipv6_cidr_blocks = ingress.value.ipv6_cidr_blocks   
      }
   }
  ingress {
    description      = "ssh from bastion servers"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
   security_groups   =  [aws_security_group.allow_ssh.id]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_ssh_bastion"
  }
}

# create keypair for service box host
resource "tls_private_key" "service_pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "service_box" {
  key_name   = "${var.project_prefix}-service-box"     
  public_key = tls_private_key.service_pk.public_key_openssh

  # provisioner "local-exec" {
  #   command = "echo '${tls_private_key.service_pk.private_key_pem}' > ./ssh_keys/${var.project_prefix}-service-box.pem && chmod 600 ./ssh_keys/${var.project_prefix}-service-box.pem"
  # }
}

# get private subnets
data "aws_subnet_ids" "private" {
  vpc_id = var.vpc_id

  tags = {
    Tier = "Private"
  }
}
locals {
  private_subnet_ids =  tolist(data.aws_subnet_ids.private.ids)
}

# create service box 
resource "aws_instance" "service_box" {
  count                  = var.create_service_box ? var.service_box.count : 0
  ami                    = var.service_box.ami
  instance_type          = var.service_box.type
  vpc_security_group_ids = [aws_security_group.sg_service.id]
  subnet_id              = element(local.private_subnet_ids, count.index)
  key_name               = aws_key_pair.service_box.key_name
  tags                   = {
   "Name" = "${var.project_prefix}-service-box-${count.index + 1}"  
   "Task" = "server"
  }
}

# get subnet's azs
data "aws_subnet" "selected" {
  count =  var.service_box.count
  id    = element(local.private_subnet_ids, count.index)
}

# create ebs volume
resource "aws_ebs_volume" "service_ebs" {
  count             = var.create_service_box ? var.service_box.count : 0
  availability_zone = element(data.aws_subnet.selected.*.availability_zone, count.index)
  size              = var.service_box.extra_ebs_size

  tags                   = {
   "Name" = "${var.project_prefix}-ebs-${count.index + 1}" 
  }
}

# attach ebs
resource "aws_volume_attachment" "ebs_att" {
  count = length(aws_ebs_volume.service_ebs.*.id)
  device_name = "/dev/sdh"
  volume_id   = element(aws_ebs_volume.service_ebs.*.id, count.index)
  instance_id = element(aws_instance.service_box.*.id, count.index)
}