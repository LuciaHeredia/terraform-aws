##### Dockerized API service input:

variable "image_name" {
  type = string
}

variable "image_keep_locally" {
  # image should be kept locally after "terraform destroy" or not
  type = bool
}

variable "container_name" {
  type = string
}

variable "container_port_internal" {
  type = number
}

variable "container_port_external" {
  type = number
}