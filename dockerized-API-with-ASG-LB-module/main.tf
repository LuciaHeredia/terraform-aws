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

#################### Docker Registry Image

resource "docker_image" "my_docker_image" {
  name = "nginx:latest"
}

#################### AWS Configurations: ECS, ASG, ALB

# ECS cluster + task + service
resource "aws_ecs_cluster" "my_ecs_cluster" {
  name = "my-ecs-cluster"
}

resource "aws_ecs_task_definition" "my_ecs_task" {
  family                = "my-ecs-task-definition"
  container_definitions = jsonencode([
    {
      name  = "my_container"
      image = docker_image.my_docker_image.image_id
      cpu   = 256
      memory = 512
      portMappings = [
        {
          hostPort      = 80
          containerPort = 80
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "my_ecs_service" {
  name            = "my-ecs-service"
  cluster         = aws_ecs_cluster.my_ecs_cluster.id
  task_definition = aws_ecs_task_definition.my_ecs_task.arn
  desired_count   = 1
  launch_type     = "EC2"
}
