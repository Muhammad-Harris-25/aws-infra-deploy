pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1' // Change if needed
    }

    stages {
        stage('Checkout SCM') {
            steps {
                checkout([$class: 'GitSCM',
                          branches: [[name: '*/main']],
                          doGenerateSubmoduleConfigurations: false,
                          extensions: [],
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
                withCredentials([usernamePassword(credentialsId: 'aws-creds',
                                                 usernameVariable: 'AWS_ACCESS_KEY_ID',
                                                 passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
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
                    ansible-playbook -i ansible/inventory.ini frontend/deploy_frontend.yml
                '''
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
