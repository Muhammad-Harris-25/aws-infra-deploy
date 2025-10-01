# aws-infra-deploy

Automated pipeline (Terraform -> Ansible) using Jenkins.

Structure:
- Terraform creates 2 EC2 instances (uses public key from `keys/jenkins_deploy_key.pub`)
- Jenkins runs `terraform apply`, generates `inventory.ini`, then runs Ansible to configure servers.

Important:
- Do **not** commit private keys. Only commit `.pub`.
- Add AWS credentials in Jenkins as `aws-creds` (Username/Password).
- Add SSH private key in Jenkins as `jenkins-ssh-key` (SSH Username with private key).
