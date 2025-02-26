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

#################### Docker Image

resource "docker_image" "nginx" {
  name = "nginx:latest"
  keep_locally = false # removes image when destroy
}

#################### AWS: VPC + Subnets + Security Group

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

# Create a security group
resource "aws_security_group" "lb_sg" {
  vpc_id = aws_vpc.main.id
  description = "Security group for the Load Balancer"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow traffic in from all sources
  }

   egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#################### ALB + Target Group + Listener

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
  target_type = "instance"
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

#################### ECS

# Create ECS cluster
resource "aws_ecs_cluster" "main" {
  name = "api-cluster"
}

# Create ECS task definition
resource "aws_ecs_task_definition" "api" {
  family                = "api-task"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  cpu                      = "256"
  memory                   = "512"
  container_definitions = jsonencode([
    {
      name  = "api-container"
      image = "${docker_image.nginx.image_id}"
      cpu   = 256
      memory = 512
      essential = true
      portMappings = [
        {
          hostPort      = 80
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
  launch_type     = "EC2"

  load_balancer {
    target_group_arn = "${aws_lb_target_group.api.arn}" 
    container_name   = "api-container"
    container_port   = 80
  }
}

#################### Launch Template + ASG

# Create a launch template for the ECS instances
resource "aws_launch_template" "ecs" {
  name_prefix  = "my-ecs-lt-"
  image_id = "ami-0884d2865dbe9de4b" # ubuntu 22.04
  instance_type = "t2.micro"

  user_data = base64encode(<<EOF
  #!/bin/bash
  echo "ECS_CLUSTER=api-cluster" >> /etc/ecs/ecs.config
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "ecs-instance"
    }
  }
}

# Create ASG
resource "aws_autoscaling_group" "ecs" {
  vpc_zone_identifier = [aws_subnet.public1.id, aws_subnet.public2.id]
  desired_capacity   = 2
  max_size           = 4
  min_size           = 1

  launch_template {
    id      = "${aws_launch_template.ecs.id}"
    version = "$Latest"
  }
}

# Ensure instances are added to the target group
resource "aws_autoscaling_attachment" "asg_tg" {
  autoscaling_group_name = aws_autoscaling_group.ecs.id
  lb_target_group_arn    = aws_lb_target_group.api.arn
}

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

