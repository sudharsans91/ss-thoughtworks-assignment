# DevOps - Mediawiki Deployment and Update

**Tools Involved**

1. Cloud - Azure
2. Version Control - Git
3. Infra Automation - Azure DevOps
4. IaC - Terraform
5. Image Creation  - Docker & Docker Hub
6. Container Orchestration - Kubernetes
7. Application deployment Update - CICD - Jenkins

**Source Code**

https://github.com/sudharsans91/ss-thoughtworks-assignment/tree/main

**My Docker Hub**
https://hub.docker.com/repository/docker/sudharshu91/tw-ss-mediawiki/general 

# Creating an Azure Kubernetes Service (AKS) using Terraform and Azure DevOps pipeline

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

***Please refer Infra-Terraform Folder for terraform file and ADO Pipeline yaml code.***

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

**Prerequisites:**

1. Install Docker and make sure docker service is up and running.
2. We should have own docker hub registry created for maintaning our image.

My Docker Hub registry for Mediawiki - https://hub.docker.com/repository/docker/sudharshu91/tw-ss-mediawiki/general 

To create our own Docker image for MediaWiki, we can use a Dockerfile. I have followed the steps defined in https://www.mediawiki.org/wiki/Manual:Running_MediaWiki_on_Red_Hat_Linux 

** Please refer Dockerfile in this repo** - https://github.com/sudharsans91/ss-thoughtworks-assignment/blob/main/Dockerfile 

we can build this Docker image using the docker build command:

```
docker build -t mediawiki-image .
```

**Push the built image to our docker hub registry**

```
docker login
docker tag ss-yw-mediawiki-1.40.1-image sudharshu91/tw-ss-mediawiki:1.40.1
docker push sudharshu91/tw-ss-mediawiki:1.40.1
```

# Deploying Mediawiki App onto Azure AKS Cluster

**Step 1: Connect to AKS Cluster**

Connect to Azure AKS Cluster using kubeconfig file

**Step 2: Authenticate with Docker Hub**

Before we can deploy the Docker image from our Docker Hub account, we need to authenticate with Docker Hub on our AKS cluster. we can use Kubernetes secrets to store our Docker Hub credentials securely.

**Step 3: Create a Kubernetes Deployment**

1. Create our own namespace to do this deployment. Here I have created namespace as "ss".
   
2. Create a Kubernetes deployment YAML file for our MediaWiki application. And we will be using loadbalancer as Kubernetes Service Type.

3. We will be using mysql as a backend database for Mediawiki app.

4. We will be using  our MediaWiki Docker image on Docker Hub.

**mediawiki-deployment.yaml**
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mediawiki-deployment
  namespace: ss
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mediawiki
  template:
    metadata:
      labels:
        app: mediawiki
    spec:
      containers:
        - name: mediawiki
          image: sudharshu91/tw-ss-mediawiki:1.40.1
          ports:
            - containerPort: 80
          env:
            - name: MYSQL_HOST
              value: mysql-service
            - name: MYSQL_PORT
              value: "3306"
            - name: MYSQL_USER
              value: your_mysql_user
            - name: MYSQL_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: mediawiki-mysql-secret
                  key: password
          volumeMounts:
            - name: mediawiki-persistent-storage
              mountPath: /var/www/html/images
      volumes:
        - name: mediawiki-persistent-storage
          persistentVolumeClaim:
            claimName: mediawiki-pvc

---
apiVersion: v1
kind: Service
metadata:
  name: mediawiki-service
  namespace: ss
spec:
  selector:
    app: mediawiki
  ports:
    - protocol: TCP
      port: 80
  type: LoadBalancer

```

**Apply the deployment to our namespace to create the MediaWiki pods:**

```
kubectl apply -f mediawiki-deployment.yaml -n ss
```
**To check the status of deployment,**
```
kubectl get deployment mediawiki-deployment -n ss
kubectl describe deployment mediawiki-deployment -n ss
```
**To check the status of pods,**
```
kubectl get pods -n ss
```
It may take some time for the LoadBalancer service to provision an external IP address.To get the service
```
kubectl get svc -n ss
```

Step 4: Access MediaWiki

Once the external IP address is available, we can access our MediaWiki application by navigating to http://<external-ip> in our web browser.

# Application Update using Jenkins Pipeline

To update a deployment running in Azure AKS (Azure Kubernetes Service) using a custom Docker image from our own Docker Hub registry using a Jenkins pipeline, we can follow these steps:

Set Up Prerequisites:

Create Jenkins VM in Azure and access the same from browser

Set up Jenkins with the necessary plugins (such as Docker, Azure Credentials, Kubernetes, etc.).

Create a Jenkins Pipeline:

Create a Jenkins pipeline script for the deployment update. We can use a Jenkinsfile for this purpose.

```
pipeline {
    agent any

    environment {
        AZURE_CREDENTIALS = credentials('azure-credentials-id')
        DOCKER_HUB_CREDENTIALS = credentials('docker-hub-credentials-id')
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
                    def image = 'sudharshu91/tw-ss-mediawiki:1.40.1'
                    def resourceGroupName = 'ss-tw-rg'
                    def aksClusterName = 'ss-tw-aks'
                    def deploymentName = 'mediawiki-deployment'

                    withCredentials([azureServicePrincipal(credentialsId: 'azure-credentials-id', variable: 'AZURE_CREDENTIALS')]) {
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

```

**Configure Jenkins Job:**
1. Azure and Docker Hub using the provided credentials in Jenkins.
2. AKS cluster and AKS credentials are correctly set up before running the pipeline.
3. Create a new Jenkins job and select "Pipeline" as the job type.
4. Configure our job to use the above Jenkinsfile
   
**Build and Trigger:**

Build and trigger the Jenkins job. It will update the deployment in our Azure AKS cluster with the new Docker image from our Docker Hub registry.