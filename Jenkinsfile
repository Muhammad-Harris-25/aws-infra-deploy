pipeline {
    agent any

    environment {
        // AWS credentials stored in Jenkins
        AWS_ACCESS_KEY_ID = ''
        AWS_SECRET_ACCESS_KEY = ''
    }

    stages {

        stage('Checkout SCM') {
            steps {
                checkout scm
            }
        }

        stage('Validate Tools') {
            steps {
                sh '''
                    terraform -v
                    aws --version
                    ansible --version
                    jq --version
                '''
            }
        }

        stage('Terraform Init & Apply') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'aws-creds',
                    usernameVariable: 'AWS_ACCESS_KEY_ID',
                    passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                )]) {
                    dir('terraform') {
                        sh '''
                            echo "Using AWS Key: $AWS_ACCESS_KEY_ID"
                            terraform init
                            terraform plan -out=tfplan
                            terraform apply -auto-approve tfplan
                        '''
                    }
                }
            }
        }

        stage('Generate Ansible Inventory') {
            steps {
                sh '''
                    chmod +x scripts/gen_inventory.sh
                    mkdir -p ansible
                    scripts/gen_inventory.sh ansible/inventory.ini
                '''
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                sh '''
                    ansible-playbook -i ansible/inventory.ini ansible/playbook.yml
                '''
            }
        }
    }

    post {
        success {
            echo "Deployment completed successfully!"
        }
        failure {
            echo "Deployment failed. Check the logs!"
        }
    }
}
