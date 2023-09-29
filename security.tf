# Create a security group for the ECS tasks
resource "aws_security_group" "nginx_app_ecs_sg" {
  name        = "ecs-security-group"
  description = "Security group for ECS tasks"
  vpc_id      = module.nginx_app_vpc.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.nginx_alb_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# create security group for alb
resource "aws_security_group" "nginx_alb_sg" {
  name        = "nginx-alb-sg"
  description = "Security group for ALB"
  vpc_id      = module.nginx_app_vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# create alb for traffic
module "nginx_app_alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"

  name = "nginx-app-alb"

  load_balancer_type = "application"

  vpc_id          = module.nginx_app_vpc.vpc_id
  subnets         = module.nginx_app_vpc.public_subnets
  security_groups = [aws_security_group.nginx_alb_sg.id]

  target_groups = [
    {
      name_prefix      = "app-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "ip"
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]
  tags = {
    Terraform = "true"
  }
}