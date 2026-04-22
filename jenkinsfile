pipeline {
    agent any

    tools {
        terraform 'terraform'
    }

    environment {
        SSH_KEY_ID = 'end_2_end_devops_ec2_ssh_key'
        GITHUB_SSH_KEY_ID = 'git_end_2_end_devops'
    }

    stages {

        stage('Checkout Source Code') {
            steps {
                git url: 'git@github.com:Pratik1805/end-to-end-devops-pipeline.git',
                    branch: 'main',
                    credentialsId: "${env.GITHUB_SSH_KEY_ID}"
            }
        }

        stage('Terraform Init') {
            steps {
                dir('terraform') {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir('terraform') {
                    sh 'terraform plan -out=tfplan'
                }
            }
        }

        stage('Validate TF') {
            when {
                expression { fileExists('terraform/tfplan') }
            }
            input {
                message "Do you want to apply this Plan?"
                ok "Apply Plan"
            }
            steps {
                echo 'Plan approved'
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('terraform') {
                    sh 'terraform apply -auto-approve tfplan'
                }
            }
        }

        stage('Fetch EC2 Public IP') {
            steps {
                dir('terraform') {
                    script {
                        // -no-color removes the ANSI escape codes ([33m)
                        // we use a shell grep/sed to ensure ONLY the IP is captured
                        def ip = sh(script: "terraform output -raw -no-color ec2_public_ip | grep -E '^[0-9.]+\$' || terraform output -raw -no-color ec2_public_ip", returnStdout: true).trim()
                        
                        // Strip any potential whitespace or trailing warnings
                        ip = ip.split('\n')[0].trim()

                        sh "echo '[web]' > ../ansible/inventory"
                        sh "echo '${ip}' >> ../ansible/inventory"
                    }
                }
            }
        }

        stage('Debug Inventory') {
            steps {
                sh 'cat ansible/inventory'
            }
        }

        stage('Run Ansible') {
            steps {
                sshagent(["${env.SSH_KEY_ID}"]) {
                    dir('ansible') {
                        sh '''
                        export ANSIBLE_HOST_KEY_CHECKING=False
                        ansible-playbook -i inventory install_docker_playbook.yml \
                        -u ec2-user
                        '''
                    }
                }
            }
        }
    }
}