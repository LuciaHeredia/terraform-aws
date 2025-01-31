# Mission: This module provisions a Dockerized API service with Auto Scaling Group and Load Balancer.
## Structure:
```
module/
├── main.tf
├── variables.tf
└── outputs.tf
```

## Provision Steps:
1. Utilize a Docker image from a specified Docker repository and tag: 
    - 
2. Set up an Auto Scaling Group ASG for the Dockerized service, enabling automatic scaling based on demand:
    -   
3. Implement a Load Balancer to distribute traffic among instances in the ASG:
    - 
4. Ensure that the system can scale in and out based on load:
    - 

## Provision Instructions:
-   To use this module in your Terraform configuration, create a *module block* in *main.tf* of your root module and insert the variables:
```
module "<NAME>" {
    
}
```
-   To run this example execute:
```
$ terraform init # installs and updates modules
$ terraform plan # generates excecution plan
$ terraform apply # to provision module
```
