# Mission: This module provisions a Dockerized API service with Auto Scaling Group and Load Balancer.
## Structure:
```
dockerized-API-with-ASG-LB-module/
├── main.tf
├── variables.tf
└── outputs.tf
```

## Provision Steps:
1. Utilize a Docker image from a specified Docker repository: 
    -   Using Terraform to deploy an **Nginx service** in a Docker container involves several steps: 
        -   Setting up Terraform Configuration  
        -   Defining the Docker image 
        -   Configuring the Docker container  
    - To test this:
        -   In **Provision Instructions** bellow, use only the sections *Module* and *Dockerized API Service*, and run.
        -   To see the running image use:
            ```
            $ docker ps
            ```
        -   To access the API service, paste in your browser: http://localhost:8000/
2. Set up an Auto Scaling Group ASG for the Dockerized service, enabling automatic scaling based on demand:
    -   ???
3. Implement a Load Balancer to distribute traffic among instances in the ASG:
    -   ???
4. Ensure that the system can scale in and out based on load:
    -   ???

## Provision Instructions:
-   To use this module in your Terraform configuration, create a *module block* in *main.tf* of your root module and insert the variables:
    ```
    module "<NAME>" {
        # Module
        source = "./dockerized-API-with-ASG-LB-module"

        # Dockerized API Service
        # (providers source and version must be declared directly in main.tf)
        image_name = "nginx:latest"
        image_keep_locally = false 
        container_name = "api-service-container"
        container_port_internal = 80
        container_port_external = 8000
    }
    ```
-   To run this example execute:
    ```
    $ terraform init # installs and updates modules
    $ terraform plan # generates excecution plan
    $ terraform apply # to provision module
    ```
