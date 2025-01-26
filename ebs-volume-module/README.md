# Mission: Terraform module that creates EC2 instance with EBS volume and mounts it.
## Steps:
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
    - Launch an EC2 instance with a specified: **AMI**, **instance type**, and **root volume size**. 
    - Attach an additional EBS volume to the instance with a specified size and volume type. 
    -	Mount the EBS volume to the instance.
-   variables.tf:
    - **AMI**, **instance type**, and **root volume size**. 
-   outputs.tf:
    - **instance id** and **instance public id**.

## Structure:
```
ebs-volume-module/
├── main.tf
├── variables.tf
└── outputs.tf
```

## Provision Instructions:
-   To use this module in your Terraform configuration, create a *module block* in your *main.tf* file and insert the variables:
```
module "<NAME>" {
source = "./ebs-volume-module"

ami_id           = "ami-0884d2865dbe9de4b" # ubuntu 22.04
instance_type    = "t2.micro"
}
```
-   To run this example execute:
```
$ terraform init
$ terraform plan
$ terraform apply
```
