### EC2 instance
provider "aws" {
    region = var.region_name
}

resource "aws_instance" "ec2" {
    ami = var.ami_id
    instance_type = var.instance_type

    root_block_device {
        volume_size = var.instance_root_vol_size # in GB
    }

    tags = {
        Name = "Terraform EC2"
    } 
}

### EBS volume
resource "aws_ebs_volume" "ebs_vol" {
    availability_zone = aws_instance.ec2.availability_zone
    size = var.ebs_vol_size # in GB
    tags = {
        Name = "Terraform EBS"
    } 
    depends_on = [ aws_instance.ec2 ]
}

### EBS volume attach
resource "aws_volume_attachment" "attach_ebs_vol" {
    device_name = var.device_name_for_ebs_mount
    volume_id = aws_ebs_volume.ebs_vol.id
    instance_id = aws_instance.ec2.id
    depends_on = [ aws_ebs_volume.ebs_vol ]
}