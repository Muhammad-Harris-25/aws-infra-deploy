pipeline {
  agent any

  environment {
    TF_DIR       = 'terraform'
    INVENTORY    = 'inventory.ini'
    ANSIBLE_PLAY = 'frontend/deploy_frontend.yml'
    AWS_REGION   = 'eu-north-1'
  }

  options {
    ansiColor('xterm')
    timestamps()
  }

  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Validate tools') {
      steps {
        sh '''
          terraform -v || true
          aws --version || true
          jq --version || true
          ansible --version || true
        '''
      }
    }

    stage('Terraform Apply') {
      steps {
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

              terraform init -input=false
              terraform apply -auto-approve -input=false

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
          echo "----- inventory -----"
          cat ${INVENTORY}
        '''
      }
    }

    stage('Run Ansible') {
      steps {
        withCredentials([sshUserPrivateKey(credentialsId: 'jenkins-ssh-key', keyFileVariable: 'SSH_KEY')]) {
          sh '''
            #!/bin/bash
            ansible-playbook -i ${INVENTORY} ${ANSIBLE_PLAY} --private-key $SSH_KEY -u ubuntu -o StrictHostKeyChecking=no
          '''
        }
      }
    }
  }

  post {
    success { echo "Pipeline completed successfully." }
    failure { echo "Pipeline failed. Inspect console output." }
  }
}
