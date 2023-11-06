# DevOps - Mediawiki Deployment and Update

**Tools Involved**

| Cloud | Azure |
| Version Control | Git |
| Infra Automation | Azure DevOps |
| IaC | Terraform |
| Image Creation | Docker & Docker Hub |
| Container Orchestration | Kubernetes |
| Application deployment Update | CICD - Jenkins |

1. Cloud - Azure
2. Version Control - Git
3. Infra Automation - Azure DevOps
4. IaC - Terraform
5. Image Creation  - Docker & Docker Hub
6. Container Orchestration - Kubernetes
7. Application deployment Update - CICD - Jenkins

**Creating an Azure Kubernetes Service (AKS) using Terraform and Azure DevOps pipeline**

**Prerequisites:**

1. An Azure subscription.
2. An Azure DevOps organization and project.
3. Install Terraform and the Azure CLI on Azure DevOps Agent machine or we can use default ADO Agent.
4. Azure Service Principal to authenticate azure subscription.

Create an Azure Service Principal and assign the necessary permissions to it. we can do this through the Azure CLI or Azure Portal.
Configure Azure DevOps:

Create a new Azure DevOps project if we haven't already.
Set up a Service Connection to link our Azure DevOps project to our Azure subscription. Use the Service Principal created in step 2.
Initialize a Git Repository:

Create a Git repository in our Azure DevOps project where we store our Terraform code.
Create the Terraform Configuration:

Create a Terraform configuration that defines our AKS cluster. we'll need to include resources like a Resource Group, AKS Cluster, and optionally other Azure resources.
Ensure we use the AzureRM provider for Terraform to interact with Azure.

**Please refer Infra-Terraform Folder for terraform file and ADO Pipeline yaml code.**

**Store Terraform State:**

Use a remote backend for storing Terraform state, such as Azure Storage or Azure Remote Backend in Terraform Cloud. This is crucial for state management in a multi-user environment.
Create an Azure DevOps Pipeline:

In our Azure DevOps project, create a new pipeline and choose the repository where our Terraform code is stored.
Configure Pipeline Variables:

Set up pipeline variables for sensitive information such as the Azure Service Principal credentials, resource group name, and other configuration variables.
Create Pipeline Stages:

Create pipeline stages in our Azure DevOps pipeline. Here's a simple example of stages we might include:
Initialize: Initialize Terraform and install necessary dependencies.
Plan: Run terraform plan to preview the changes to be applied.
Apply: If the plan looks good, run terraform apply to create or update the AKS cluster.
Deploy Application: Deploy our application to the AKS cluster using kubectl or other deployment tools.

**Infra-Terraform > pipelines > azure-pipelines.yml**

# Creating mediawiki image using Dockerfile

To create a Docker image for MediaWiki, we can use a Dockerfile.

Please refer **Dockerfile** in this repo

Dockerfile does the following:

It starts with the official PHP image with Apache as the base image.

Sets environment variables for the MediaWiki version and installation path.

Installs system dependencies and PHP extensions required for MediaWiki to function properly.

Downloads and extracts the MediaWiki source code to the specified installation path.

Configures Apache, enabling the rewrite module and setting permissions on the MediaWiki files.

Exposes port 80 to allow access to the web server.

Defines the default command to start Apache.

we can build this Docker image using the docker build command:

'''
docker build -t mediawiki-image .
'''

**Push the built image to our docker hub registry**

docker login

docker tag ss-yw-mediawiki-1.40.1-image sudharshu91/tw-ss-mediawiki:1.40.1

docker push sudharshu91/tw-ss-mediawiki:1.40.1

MediaWiki Docker image in our Docker Hub account, we can deploy it to our existing AKS cluster by creating a Kubernetes deployment and service.

**Step 1: Authenticate with Docker Hub**

Before we can deploy the Docker image from our Docker Hub account, we need to authenticate with Docker Hub on our AKS cluster. we can use Kubernetes secrets to store our Docker Hub credentials securely.

Create a Docker Hub secret:

**Step 2: Create a Kubernetes Deployment**

Create a Kubernetes deployment YAML file for our MediaWiki application. Replace our-image-name with the name of our MediaWiki Docker image on Docker Hub.

Apply the deployment to create the MediaWiki pod:

kubectl apply -f mediawiki-deployment.yaml
Step 3: Create a Kubernetes Service

Create a Kubernetes service YAML file to expose the MediaWiki deployment:

Apply the service definition to create a LoadBalancer service:

kubectl apply -f mediawiki-service.yaml
It may take some time for the LoadBalancer service to provision an external IP address.

Step 4: Access MediaWiki

Once the external IP address is available, we can access our MediaWiki application by navigating to http://<external-ip> in our web browser.

# App Update using Jenkins

To update a deployment running in Azure AKS (Azure Kubernetes Service) using a custom Docker image from our own Docker Hub registry using a Jenkins pipeline, we can follow these steps:

Set Up Prerequisites:

Ensure we have an Azure AKS cluster up and running.
Make sure we have a Docker image of our application hosted in our Docker Hub registry.
Set up Jenkins with the necessary plugins (such as Docker, Azure Credentials, Kubernetes, etc.).
Create a Jenkins Pipeline:
Create a Jenkins pipeline script for the deployment update. We can use a Jenkinsfile for this purpose.
'''
pipeline {
    agent any

    environment {
        AZURE_CREDENTIALS = credentials('our-azure-credentials-id')
        DOCKER_HUB_CREDENTIALS = credentials('our-docker-hub-credentials-id')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Update AKS Deployment') {
            steps {
                script {
                    def image = 'our-docker-hub-username/our-image-name:latest'
                    def appName = 'our-application-name'
                    def resourceGroupName = 'our-resource-group-name'
                    def aksClusterName = 'our-aks-cluster-name'
                    def deploymentName = 'our-deployment-name'

                    withCredentials([azureServicePrincipal(credentialsId: 'our-azure-credentials-id', variable: 'AZURE_CREDENTIALS')]) {
                        sh """
                        az aks get-credentials --resource-group $resourceGroupName --name $aksClusterName
                        kubectl set image deployment/$deploymentName $appName=$image
                        kubectl rollout status deployment/$deploymentName
                        """
                    }
                }
            }
        }
    }
}
'''
Configure Jenkins Job:
Azure and Docker Hub using the provided credentials in Jenkins.
AKS cluster and AKS credentials are correctly set up before running the pipeline.
Create a new Jenkins job and select "Pipeline" as the job type.
Configure our job to use the above Jenkinsfile
Build and Trigger:

Build and trigger the Jenkins job. It will update the deployment in our Azure AKS cluster with the new Docker image from our Docker Hub registry.