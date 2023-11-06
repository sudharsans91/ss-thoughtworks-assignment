pipeline {
    agent any

    environment {
        AZURE_CREDENTIALS = credentials('your-azure-credentials-id')
        DOCKER_HUB_CREDENTIALS = credentials('your-docker-hub-credentials-id')
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
                    def image = 'your-docker-hub-username/your-image-name:latest'
                    def appName = 'your-application-name'
                    def resourceGroupName = 'your-resource-group-name'
                    def aksClusterName = 'your-aks-cluster-name'
                    def deploymentName = 'your-deployment-name'

                    withCredentials([azureServicePrincipal(credentialsId: 'your-azure-credentials-id', variable: 'AZURE_CREDENTIALS')]) {
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
