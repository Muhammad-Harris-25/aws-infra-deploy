pipeline {
    agent any

    environment {
        TF_DIR = 'terraform'  // your Terraform directory
        AWS_REGION = 'eu-north-1'
    }

    options {
        timestamps()
        ansiColor('xterm')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout([
                    $class: 'GitSCM', 
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
                    #!/bin/bash
                    terraform -v
                    aws --version
                    ansible --version
                    jq --version
                '''
            }
        }

        stage('Terraform Init & Apply') {
            environment {
                AWS_ACCESS_KEY_ID = credentials('aws_access_key')
                AWS_SECRET_ACCESS_KEY = credentials('aws_secret_key')
            }
            steps {
                dir("${TF_DIR}") {
                    sh '''
                        #!/bin/bash
                        set -euo pipefail

                        terraform init -input=false
                        terraform plan -out=tfplan -input=false
                        terraform apply -auto-approve tfplan

                        terraform output -json > ${WORKSPACE}/tf-output.json
                    '''
                }
            }
        }

        stage('Generate Inventory') {
            steps {
                sh '''
                    #!/bin/bash
                    if [[ -f "${WORKSPACE}/tf-output.json" ]]; then
                        jq -r '.instance_public_ips.value[]' ${WORKSPACE}/tf-output.json > ${WORKSPACE}/inventory.ini
                        echo "Inventory generated:"
                        cat ${WORKSPACE}/inventory.ini
                    else
                        echo "Terraform output file not found!"
                        exit 1
                    fi
                '''
            }
        }

        stage('Run Ansible') {
            steps {
                sh '''
                    #!/bin/bash
                    ansible-playbook -i ${WORKSPACE}/inventory.ini ../playbook.yml
                '''
            }
        }
    }

    post {
        always {
            echo "Pipeline finished!"
        }
        success {
            echo "Deployment succeeded."
        }
        failure {
            echo "Deployment failed. Check the logs."
        }
    }
}
