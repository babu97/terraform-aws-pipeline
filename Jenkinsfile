pipeline {
    agent {
        kubernetes {
            label 'my-terraform-agent'
            defaultContainer 'jnlp'
            yaml """
            apiVersion: v1
            kind: Pod
            metadata:
              namespace: tools
            spec:
              containers:
              - name: terraform
                image: hashicorp/terraform:latest
                command:
                - cat
                tty: true
            """
        }
    }

    environment {
        TF_CLI_ARGS = '-no-color'
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    checkout scm
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                container('terraform') {
                    script {
                        withCredentials([aws(credentialsId: 'AWS_CREDENTIALS', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                            sh 'terraform init'
                            sh 'terraform plan -out=tfplan'
                        }
                    }
                }
            }
        }

        stage('Terraform Apply') {
            when {
                    expression { env.BRANCH_NAME == 'main' }
                     expression { currentBuild.rawBuild.getCause(hudson.model.Cause$UserIdCause) != null }
                
            }
            steps {
                container('terraform') {
                    script {
                        // Ask for manual confirmation before applying changes
                        input message: 'Do you want to apply changes?', ok: 'Yes'
                        withCredentials([aws(credentialsId: 'AWS_CREDENTIALS', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                            sh 'terraform init'
                            sh 'terraform apply  -out=tfplan'
                        }
                    }
                }
            }
        }
    }
}
