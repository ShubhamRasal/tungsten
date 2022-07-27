
variable "vpc_id" {
  type = string
}

variable "project_prefix" {
  type =  string
}

# bastion host
variable "create_bastion" {
    type =  bool
    default = true
}

variable "bastion" {
  type = object({
    count = number
    ami   = string
    type  = string
  })
}

# service box
variable "sg_service_rules" {
  type = list
  # default = [
  #   {
  #     ingress_port = 80
  #     protocol = "tcp"
  #     cidr_blocks = ["0.0.0.0/0"]
  #     ipv6_cidr_blocks = ["::/0"]
  #     description = "allow_http"
  #   },
  #   {
  #     ingress_port = 5000
  #     protocol = "tcp"
  #     cidr_blocks = ["0.0.0.0/0"]
  #     ipv6_cidr_blocks = ["::/0"]
  #     description = "allow_http"
  #   }
  # ]
}

variable "create_service_box" {
      type = bool
      default = true
}

variable "service_box" {
  type = object({
    count = number
    ami   = string
    type  = string
    extra_ebs_size = number
  })
}


variable "alb_target_groups" {
  type =  list
  # default = [
  #   {
  #     name = "web-service"
  #     port = 80
  #     protocol = "HTTP"
  #     health_check_path    = "/"
  #     priority  = 100
  #     host_header = ["app.creatorsbyheart.tech"]
  #   },
  #   {
  #     name = "registry"
  #     port = 5000
  #     protocol = "HTTP"
  #     health_check_path    = "/health"
  #     priority  = 99
  #     host_header = ["registry.creatorsbyheart.tech"]
  #   }
  # ]
}

variable "certificate_arn" {
   type = string
}


