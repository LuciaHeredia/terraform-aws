#################### Terraform Configurations: Docker, AWS

terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
      version = "3.0.2"
    }
    aws = {
      source = "hashicorp/aws"
      version = "4.45.0"
    }
  }
}

# Docker configurations
provider "docker" {}

# AWS configurations
provider "aws" {
  region  = "us-east-2"
  #access_key = "enter_access_key_here" # Enter AWS IAM 
  #secret_key = "enter_secret_key_here" # Enter AWS IAM 
}

#################### AWS: VPC + Subnets

# Create VPC 
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
}

# Create public subnets 
resource "aws_subnet" "public1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-2a"
}
resource "aws_subnet" "public2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-2b"
}

# Create internet gateway
resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id
}

# Create route table for public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}

#################### Security Group + ALB + Target Group + Listener

# Create a security group
resource "aws_security_group" "lb_sg" {
  name = "lb-sg"
  vpc_id = aws_vpc.main.id
  description = "Security group for the Load Balancer"

  ingress {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow traffic in from all sources
  }

   egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create Load Balancer
resource "aws_lb" "api" {
  name               = "api-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.public1.id, aws_subnet.public2.id]
  security_groups    = [aws_security_group.lb_sg.id]
}

# Create Target Group
resource "aws_lb_target_group" "api" {
  name    = "api-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  target_type = "ip"
}

# Create Load Balancer Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.api.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }
}

#################### Security Group + ECS

# Create a security group
resource "aws_security_group" "ecs_sg" {
  name = "ecs-sg"
  vpc_id = aws_vpc.main.id
  description = "Security group for ECS Cluster"

  ingress {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow traffic in from all sources
  }

   egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Allow traffic from ALB security group on required port 
resource "aws_security_group_rule" "ecs_open_to_alb" {
  type = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  source_security_group_id = aws_security_group.ecs_sg.id
  security_group_id = aws_security_group.lb_sg.id
}

# Create ECS cluster
resource "aws_ecs_cluster" "main" {
  name = "api-cluster"
}

# Create ECS task definition
resource "aws_ecs_task_definition" "api" {
  family = "api-task"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = 256
  memory = 512
  container_definitions = jsonencode([
    {
      name  = "api-container"
      image = "nginx:latest"
      cpu = 256
      memory = 512
      essential = true
      portMappings = [
        {
          hostPort= 80
          containerPort = 80
        }
      ]
    }
  ])
}

# Create ECS service
resource "aws_ecs_service" "api" {
  name            = "api-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.api.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets = [aws_subnet.public1.id, aws_subnet.public2.id]
    security_groups    = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.api.arn}" 
    container_name   = "api-container"
    container_port   = 80
  }
}

#################### ASG Policy

# Create Auto Scaling Policy
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 4
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.api.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "scale_up" {
  name               = "scale-up"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = 50.0
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}

