# create security group for bastion host
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow ssh inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description      = "ssh from anywhere"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
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


# create keypair for bastion host
resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "bastion" {
  key_name   = "${var.project_prefix}-bastion"      # Create "myKey" to AWS!!
  public_key = tls_private_key.pk.public_key_openssh

  # provisioner "local-exec" { # Create "myKey.pem" to your computer!!
  #   command = "echo '${tls_private_key.pk.private_key_pem}' > ./ssh_keys/${var.project_prefix}-bastion.pem && chmod 600 ./ssh_keys/${var.project_prefix}-bastion.pem"
  # }
}

# get public subnets
data "aws_subnet_ids" "public" {
  vpc_id = var.vpc_id

  tags = {
    Tier = "Public"
  }
}
locals {
  public_subnet_list =  tolist(data.aws_subnet_ids.public.ids)
}

# create bastion host
resource "aws_instance" "bastion" {
  count                  = var.create_bastion ? var.bastion.count : 0
  ami                    = var.bastion.ami
  instance_type          = var.bastion.type
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  subnet_id              = element(local.public_subnet_list, count.index)
  key_name               = aws_key_pair.bastion.key_name
  tags                   = {
   "Name" = "${var.project_prefix}-Bastion" 
   "Task" = "bastion"
  }
 
}
