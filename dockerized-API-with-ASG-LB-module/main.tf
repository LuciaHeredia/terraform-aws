##### Terraform Configurations: Docker, AWS

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

provider "docker" {}

provider "aws" {
  region  = "us-east-2"
  #access_key = "enter_access_key_here" # Enter AWS IAM 
  #secret_key = "enter_secret_key_here" # Enter AWS IAM 
}

##### Dockerized API service

# Docker Image
resource "docker_image" "api_service" {
  name = var.image_name
  keep_locally = var.image_keep_locally
}

# Docker Container
resource "docker_container" "api_service_container" {
  image = docker_image.api_service.image_id
  name = var.container_name
  ports {
    internal = var.container_port_internal
    external = var.container_port_external
  }
}

##### AWS Configurations: ECR, ECS, ASG, ALB

# ECR repository
resource "aws_ecr_repository" "my_ecr_repo" {
  name = "app-repo"
}

# ECS cluster
#resource "aws_ecs_cluster" "my_ecs_cluster" {
#  name = "my-cluster"
#}