# Create an ECS cluster
resource "aws_ecs_cluster" "nginx_app_ecs_cluster" {
  name = "nginx-app-ecs-cluster"
}

# Create a task definition for the ECS service
resource "aws_ecs_task_definition" "nginx_app_task_definition" {
  family                   = "nginx-app-task-family"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"] # Stating that we are using ECS Fargate
  memory                   = 512         # Specifying the memory our container requires
  cpu                      = 256         # Specifying the CPU our container requires
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.ecsTaskExecutionRole.arn
  container_definitions    = <<DEFINITION
  [
    {
      "name": "my-container",
      "image": "nginx", 
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80,
          "protocol": "tcp"
        }
      ]
    }
  ]
  DEFINITION
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }
}

# Create an ECS service
resource "aws_ecs_service" "ecs_service" {
  name            = "nginx-app-ecs-service"
  cluster         = aws_ecs_cluster.nginx_app_ecs_cluster.id
  task_definition = aws_ecs_task_definition.nginx_app_task_definition.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = module.nginx_app_vpc.public_subnets
    security_groups  = [aws_security_group.nginx_app_ecs_sg.id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = module.nginx_app_alb.target_group_arns[0]
    container_name   = "my-container"
    container_port   = 80
  }
}

resource "aws_s3_bucket" "nginx_bucket" {
  bucket = "nginx-bucket.seun-project.com"
}

resource "aws_s3_object" "object" {
  bucket = aws_s3_bucket.nginx_bucket.id
  key    = "index.html/"
}