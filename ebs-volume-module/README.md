# Mission: This module provisions AWS EC2 instance with EBS volume and mounts it.
## Structure:
```
ebs-volume-module/
├── main.tf
├── variables.tf
└── outputs.tf
```

## Provision Steps:
1. AWS authentication in AWS CLI: 
    - Set your aws configuration with your **IAM user SSH key** and **region**:
    ```
    $ aws configure
    ```
    ```
    AWS Access Key ID [None]: <accesskey>
    AWS Secret Access Key [None]: <secretkey>
    Default region name [None]: <region>
    Default output format [None]:
    ```
2. Create a directory and inside create the following files: 
    -   main.tf: 
        - Launch an EC2 instance with a specified: **region**, **AMI**, **instance type**, **root volume size**, **tags**. 
        - Create an additional EBS volume to the instance with: **availability zone**, **size**, **volume type**, **tags**.
        - Mount the EBS volume to the instance: **device name**, **volume id**, **instance id**.
    -   variables.tf:
        - **region**, **AMI**, **instance type**.
    -   outputs.tf:
        - **instance id**, **instance public id**.

## Provision Instructions:
-   To use this module in your Terraform configuration, create a *module block* in *main.tf* of your root module and insert the variables:
```
module "<NAME>" {
    # EC2
    source = "./ebs-volume-module"
    region_name = "us-east-2"
    ami_id           = "ami-0884d2865dbe9de4b" # ubuntu 22.04
    instance_type    = "t2.micro"
    instance_root_vol_size = 10 # in GB

    # EBS
    ebs_vol_size = 2 # in GB
    device_name_for_ebs_mount = "/dev/sdf"
}
```
-   To run this example execute:
```
$ terraform init # installs and updates modules
$ terraform plan # generates excecution plan
$ terraform apply # to provision module
```
