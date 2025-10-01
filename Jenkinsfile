pipeline {
    agent any
    environment {
        TERRAFORM_DIR = 'terraform'
        INVENTORY_FILE = 'ansible/inventory.ini'
    }
    stages {
        stage('Checkout SCM') {
            steps {
                checkout([$class: 'GitSCM', 
                    branches: [[name: '*/main']], 
                    userRemoteConfigs: [[
                        url: 'https://github.com/Muhammad-Harris-25/aws-infra-deploy.git',
                        credentialsId: 'github_pat'
                    ]]
                ])
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
                // AWS credentials from Jenkins
                withCredentials([usernamePassword(credentialsId: 'aws-creds',
                                                 usernameVariable: 'AWS_ACCESS_KEY_ID',
                                                 passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    dir(TERRAFORM_DIR) {
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
                dir(TERRAFORM_DIR) {
                    // Generate dynamic inventory from Terraform output
                    sh '''
                        terraform output -json > tf-output.json
                        jq -r '.instance_public_ips.value[]' tf-output.json > ../ansible/inventory.ini
                    '''
                }
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                dir('ansible') {
                    sh '''
                        ansible-playbook -i inventory.ini site.yml
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'Deployment completed successfully!'
        }
        failure {
            echo 'Deployment failed. Check the logs!'
        }
    }
}
