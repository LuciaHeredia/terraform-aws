# Mission: This module provisions a Dockerized API service with Auto Scaling Group and Load Balancer.
## Structure:
```
dockerized-API-with-ASG-LB-module/
├── main.tf
└── variables.tf
```

## Provision Steps:
1. Utilize a Docker image from a specified Docker repository: 
    -   Using Terraform to deploy an **Nginx service** in a **Docker container** involves several steps: 
        -   Setting up *Docker provider* in *Terraform Configuration*.
        -   Defining the **Docker Image**. Includes: **Image name**.
2. Set up **AWS** Configuration:
    -   Setting up *AWS provider* in *Terraform Configuration*.
    -   Set your **AWS** configuration with your **IAM user SSH key** and **region**.
3. Set up **ECS**:
    -   *ECS cluster* - This cluster will host your containerized application.
    -   *ECS task definition* - It specify how your containers should run within the *ECS cluster*. Includes: **Docker image** from a repository, **CPU**, **memory requirements**, **networking configuration**.
    -   *ECS service* - This service runs and maintains your desired number of tasks simultaneously in the ECS cluster.
4. Set up an Auto Scaling Group ASG for the Dockerized service, enabling automatic scaling based on demand:
    -   ???
5. Implement a Load Balancer to distribute traffic among instances in the ASG:
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
