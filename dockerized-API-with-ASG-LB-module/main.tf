##### Dockerized API service:

# Terraform Configuration
terraform {
  required_providers {
    docker = {
      source = var.provider_source
      version = var.provider_version
    }
  }
}

provider "docker" {}

# Docker Image
resource "docker_image" "example" {
  name = var.image_name
  keep_locally = var.image_keep_locally
}

# Docker Container
resource "docker_container" "example" {
  image = docker_image.example.latest
  name = var.container_name
  ports {
    internal = var.container_port_internal
    external = var.container_port_external
  }
}