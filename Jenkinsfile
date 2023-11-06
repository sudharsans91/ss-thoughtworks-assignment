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
