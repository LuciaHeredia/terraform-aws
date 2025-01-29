variable "region_name" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "instance_root_vol_size" {
  type = number
}

variable "ebs_vol_size" {
  type = number
}

variable "device_name_for_ebs_mount" {
  type = string
}
