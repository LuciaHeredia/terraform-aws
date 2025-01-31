##### Dockerized API service:

# Terraform Docker Configuration
terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

provider "docker" {}

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