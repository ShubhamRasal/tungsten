variable "aws_region" {
  type = string
}

variable "vpc_cidr" {
   type =  string
   default = "10.0.0.0/16"
}

variable "max_az" {
  type = number

}

variable "project_prefix" {
  type =  string
}
