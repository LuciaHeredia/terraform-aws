# Mission: This module provisions a Dockerized API service with Auto Scaling Group and Load Balancer.
## Structure:
```
dockerized-API-with-ASG-LB-module/
├── main.tf
└── variables.tf
```

## Terraform Provision Steps:
1. Utilize a **Docker image** from a specified **Docker repository**: 
    -   Using Terraform to deploy an **Nginx service** in a **Docker container** involves several steps: 
        -   Setting up *Docker provider* in *Terraform Configuration*.
        -   Defining the **Docker Image**. Includes: *Image name*.
2. Set up **AWS** Cloud:
    -   Setting up *AWS provider* in *Terraform Configuration*.
    -   Set your **AWS configuration** with your *IAM user SSH key* and *region*.
    -   Set up **VPC**.
    -   Set up **Subnets** (public, private).
    -   Set up **Security Group**.
3. Set up **Load Balancer**:
    > ALB (Application Load Balancer) for distributing traffic among instances in the **ASG**.
    -   ???
4. Set up **ECS**:
    > ECS (Elastic Container Service) for running Docker containers.
    -   Set up **Launch template** for the *ECS instances*.
    -   Set up **ECS cluster**.
        > This cluster will host your containerized application.
    -   Set up **ECS task definition**:
        > It specify how your containers should run within the **ECS cluster**.
        -   Includes: **Docker image** from a repository, *CPU*, *memory requirements*, *networking configuration*.
    -   Set up **ECS service**.
        > This service runs and maintains your desired number of tasks simultaneously in the **ECS cluster**.
5. Set up **ASG**:
    > ASG (Auto Scaling Group) to adjust the number of instances based on demand.
    -   ???
6. Ensure that the system can scale in and out based on load:
    -   ???

## Provision Instructions:
-   To use this module in your Terraform configuration, create a *module block* in *main.tf* of your root module and insert the variables:
    ```
    module "<NAME>" {
        # Module
        source = "./dockerized-API-with-ASG-LB-module"
    }
    ```
-   To run this example execute:
    ```
    $ terraform init # installs and updates modules
    $ terraform plan # generates excecution plan
    $ terraform apply # to provision module
    ```
-   To destroy all:
    ```
    $ terraform destroy
    ```
