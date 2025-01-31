/*module "ebs-volume-module" {
   # EC2
    source = "./ebs-volume-module"
    region_name = "us-east-2"
    ami_id           = "ami-0884d2865dbe9de4b" # ubuntu 22.04
    instance_type    = "t2.micro"
    instance_root_vol_size = 10 # in GB

    # EBS
    ebs_vol_size = 2 # in GB
    device_name_for_ebs_mount = "/dev/sdf"
}*/

module "dockerized-API-with-ASG-LB-module" {
    # Module
    source = "./dockerized-API-with-ASG-LB-module"

    # Dockerized API Service
    provider_source = "kreuzwerker/docker"
    provider_version = "~> 2.13.0"
    image_name = "nginx:latest"
    image_keep_locally = false 
    container_name = "dockerized-API-service"
    container_port_internal = 80
    container_port_external = 8000

    # EC2
    region_name = "us-east-2"

}