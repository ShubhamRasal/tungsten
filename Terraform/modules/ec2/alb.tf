# instance load balancer
resource "aws_lb_target_group" "service_box_grp" {
  count    = length(var.alb_target_groups)
  name     =  "${var.project_prefix}-${var.alb_target_groups[count.index].name}-target-grp"
  port     = var.alb_target_groups[count.index].port
  protocol = var.alb_target_groups[count.index].protocol
  vpc_id   = var.vpc_id
  health_check {
    enabled = true
    healthy_threshold = 3
    path    = var.alb_target_groups[count.index].health_check_path
  }
}

resource "aws_lb_target_group_attachment" "service_box" {
  count            = length(aws_instance.service_box.*.id) * length(var.alb_target_groups)
  target_group_arn = element(aws_lb_target_group.service_box_grp.*.arn, count.index)
  target_id        = element(aws_instance.service_box.*.id, count.index)
  port             =  element(var.alb_target_groups.*.port, count.index)
}

resource "aws_security_group" "loadbalancer" {
  name        = "${var.project_prefix}-loadbalancer-sg"
  description = "Allow TLS inbound traffic for loadbalancer"
  vpc_id      =  var.vpc_id

  ingress {
    description      = "HTTPS ALLOW"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Allow 80"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups  = [ aws_security_group.sg_service.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  depends_on = [
    aws_security_group.sg_service
  ]
}

resource "aws_lb" "lb" {
  name               = "${var.project_prefix}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.loadbalancer.id]
  subnets            = local.public_subnet_list
  enable_deletion_protection = false
}

# listener
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn
  
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Wrong Path!"
      status_code  = "200"
    }
  }

}

resource "aws_lb_listener_rule" "backends" {
  count = length(aws_lb_target_group.service_box_grp.*.id)
  listener_arn = aws_lb_listener.front_end.arn
  priority     = var.alb_target_groups[count.index].priority

  action {
    type             = "forward"
    target_group_arn = element(aws_lb_target_group.service_box_grp.*.arn, count.index)
  }

  condition {
    host_header {
      values = var.alb_target_groups[count.index].host_header
    }
  }
}
