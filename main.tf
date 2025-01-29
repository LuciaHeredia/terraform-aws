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
