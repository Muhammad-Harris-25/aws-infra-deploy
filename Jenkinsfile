pipeline {
    agent any

    environment {
        TF_DIR        = 'terraform'
        INVENTORY     = 'inventory.ini'
        ANSIBLE_PLAY  = 'frontend/deploy_frontend.yml'
        AWS_REGION    = 'eu-north-1'   // change as needed
    }

    options {
        ansiColor('xterm')   // requires AnsiColor plugin
        timestamps()
        skipDefaultCheckout(true)   // we’ll do explicit checkout
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
#!/bin/bash
terraform -v || true
aws --version || true
jq --version || true
ansible --version || true
'''
            }
        }

        stage('Terraform Apply') {
            steps {
                // AWS credentials as Username/Password type
                withCredentials([usernamePassword(credentialsId: 'aws-creds',
                                                 usernameVariable: 'AWS_ACCESS_KEY_ID',
                                                 passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    dir(env.TF_DIR) {
                        sh '''
#!/bin/bash
set -euo pipefail

export AWS_REGION=${AWS_REGION}
export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}

echo "Initializing Terraform..."
terraform init -input=false

echo "Applying Terraform..."
terraform apply -auto-approve -input=false

echo "Exporting Terraform outputs..."
terraform output -json > ${WORKSPACE}/tf-output.json
'''
                    }
                }
            }
        }

        stage('Generate Inventory') {
            steps {
                sh '''
#!/bin/bash
chmod +x ./scripts/gen_inventory.sh
./scripts/gen_inventory.sh ${TF_DIR} ${INVENTORY}

echo "----- Inventory -----"
cat ${INVENTORY}
'''
            }
        }

        stage('Run Ansible') {
            steps {
                // SSH key configured in Jenkins credentials
                sshagent(credentials: ['jenkins-ssh-key']) {
                    sh '''
#!/bin/bash
ansible-playbook -i ${INVENTORY} ${ANSIBLE_PLAY} --ssh-extra-args='-o StrictHostKeyChecking=no'
'''
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully."
        }
        failure {
            echo "Pipeline failed. Inspect console output."
        }
    }
}
