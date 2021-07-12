author = "shubham"
project_name = "one2n"
env = "dev"
aws_region = "ap-south-1"
vpc_cidr = "10.0.0.0/16"
max_az = 2

rds = {
    allocated_storage = 10
    engine            = "mysql"
    engine_version    = "5.7" 
    instance_class    = "db.t2.micro"
    name              = "mydb"

}

bastion = {
    ami = "ami-011c99152163a87ae"
    count = 1
    type = "t2.nano"
}
service_box = {
    ami = "ami-011c99152163a87ae"
    count = 1
    type = "t2.micro"
    extra_ebs_size = 8
}
sg_service_rules = [
    {
      ingress_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      description = "allow_http"
    },
    {
      ingress_port = 5000
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      description = "allow_http"
    }
]

alb_target_groups =   [
   {
      name = "web-service"
      port = 80
      protocol = "HTTP"
      health_check_path    = "/"
      priority  = 100
      host_header = ["app.creatorsbyheart.tech"]
    },
    {
      name = "registry"
      port = 5000
      protocol = "HTTP"
      health_check_path    = "/"
      priority  = 99
      host_header = ["registry.creatorsbyheart.tech"]
    }
]



s3_bucket_name = "one2n-demo-bucket"

certificate_arn = "arn:aws:acm:ap-south-1:263647842310:certificate/e137a22e-5298-4895-bfaf-a5a4725872b6"