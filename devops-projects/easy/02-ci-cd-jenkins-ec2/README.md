# 02-ci-cd-jenkins-ec2 CI/CD Pipeline with Jenkins on EC2

## Overview:

In this project, we are building a CI/CD pipeline using Jenkins to automate the deployment of a web application onto an AWS EC2 instance. The pipeline will pull the latest code from a GitHub repository, build the application, and deploy it on an EC2 instance automatically, streamlining the entire deployment process.

## What we are doing:

We are automating the deployment process by setting up a Jenkins pipeline that:
- Clones the source code from GitHub.
- Builds the application.
- Deploys the application on an EC2 instance.

The EC2 instance will host the application, making it available for access via a public IP.

## Why we are doing it:

Automating CI/CD pipelines for EC2 deployments ensures that code changes are consistently deployed to production environments without manual intervention. This reduces human errors, speeds up the deployment process, and provides continuous feedback on the application’s status.

With Jenkins managing the automation and EC2 handling the deployment, developers can focus on writing code, while the infrastructure handles the building, testing, and deployment steps seamlessly.

## Real-Life Use Case:

At companies like Netflix, thousands of microservices are deployed and updated on EC2 instances to deliver a seamless streaming experience. When engineers push code updates to GitHub, Jenkins automatically pulls the code, tests it, and deploys it onto EC2 instances, ensuring that the latest features are live with minimal delay.

This kind of automation reduces downtime, ensures fast releases, and allows for rapid testing and validation in production environments.

## Tools and Technologies

- **AWS EC2**: For jenkins and hosting the application.
- **Jenkins**: To automate the deployment process. Also `Publish Over SSH` jenkins plugin.
- **GitHub**: To store and manage the application's source code.
- **SSH**: To access and configure the EC2 instance.

## Setup Instructions

### Step 1: Launch EC2 Instance for hosting Web Application

1. Go to the [AWS Management Console](https://aws.amazon.com/console/) and launch an EC2 instance.
2. Select **Ubuntu 20.04 LTS** as the base AMI.
3. Choose an instance type (use **t2.micro** for free-tier).
4. Configure Security Groups:
   - Allow inbound SSH (port 22), Application (port 3000), HTTPS (port 443).
5. Download the SSH key pair for accessing the instance.
6. Test SSH into the instance using:
   ```bash
   ssh -i <your-key-pair>.pem ubuntu@<ec2-public-ip>
   ```

### Step 2: Set Up Jenkins on separate EC2 instance

1. Refer to the [01-CI-CD-Jenkins-Docker](https://github.com/swapnilyavalkar/aws-devops-realworld-projects/tree/main/01-CI-CD-Jenkins-Docker) Project for detailed Jenkins installation steps.
2. Go to Manage Jenkins → Manage Plugins → Available tab. Search for the `Publish Over SSH` plugin and install it.

### Step 3: Attach an IAM Role to the Jenkins EC2 Instance with Necessary Permissions

**Why we are doing it:**
An IAM role is necessary to grant the EC2 instance permissions to interact with other AWS services (such as S3, EC2 management, etc.). This is critical for Jenkins to trigger deployments or to interact with other services securely.

#### Step-by-Step Instructions to Attach IAM Role to Jenkins EC2:

1. **Create an IAM Role**:
   - In the AWS Management Console, go to **IAM**.
   - Click on **Roles** in the left-hand menu, then click on the **Create Role** button.

2. **Choose Trusted Entity**:
   - Under **Select trusted entity**, choose **AWS service**.
   - Under **Use case**, select **EC2**.
   - Click **Next** to proceed.

3. **Attach Permissions**:
   - In the **Attach permissions policies** step, choose the permissions that your EC2 instance will need. For this project, you can attach the following managed policies:
     - **AmazonEC2FullAccess** (allows full access to EC2 resources)
   - Click **Next** to continue.

4. **Name the IAM Role**:
   - Provide a name for your IAM role (e.g., `Jenkins-EC2-Role`).
   - Review the settings and click **Create Role**.

5. **Attach the IAM Role to Jenkins EC2 Instance**:
   - Go to the **EC2 Dashboard** in AWS.
   - Select the jenkins EC2 instance you launched earlier.
   - Click **Actions** > **Security** > **Modify IAM Role**.
   - From the dropdown, select the IAM role you created earlier (`Jenkins-EC2-Role`).
   - Click **Update IAM Role**.

By attaching this role, your jenkins EC2 instance now has the permissions necessary to interact with the services Jenkins will need.

### Step 4: Create SSH Key Pair on Web App EC2 Instance:

1. **Log into the Web App EC2 instance**:
   - First, you need to SSH into the EC2 instance where your web app will be deployed using your existing `.pem` file:
     ```bash
     ssh -i <your-existing-key>.pem ubuntu@<ec2-public-ip>
     ```

2. **Generate a new SSH key pair on the EC2 instance**:
   - Once logged into the EC2 instance, run the following command to generate a new SSH key pair:
     ```bash
     ssh-keygen -t rsa -b 4096 -C "jenkins-deploy-key"
     ```
   - The `-t rsa` specifies the type of key (RSA), and the `-b 4096` specifies the length of the key in bits (4096 bits). The `-C` flag is used to add a comment (optional) to the key.

3. **Specify the file location**:
   - When prompted to "Enter file in which to save the key," press **Enter** to accept the default location (`/home/ubuntu/.ssh/id_rsa`).
   - You can also specify a different path if needed.

4. **Set a passphrase (optional)**:
   - You will be prompted to enter a passphrase. You can either leave this blank (press Enter) or set a passphrase for additional security.

5. **View the generated key files**:
   - After generating the SSH key pair, you will have two files in the `/home/ubuntu/.ssh/` directory:
     - **`id_rsa`**: The private key file.
     - **`id_rsa.pub`**: The public key file.

6. **Configure the Web Appp EC2 instance to allow SSH access**:
   - Ensure the EC2 instance is configured to allow SSH access using the newly generated key.
   - Copy the public key (`id_rsa.pub`) to the `authorized_keys` file, which is used to authenticate SSH connections:
     ```bash
     cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
     ```

7. **Set the appropriate permissions**:
   - Make sure that the `.ssh` directory and key files have the correct permissions:
     ```bash
     chmod 700 ~/.ssh        # Directory permissions
     chmod 600 ~/.ssh/authorized_keys  # File permissions for authorized_keys
     chmod 600 ~/.ssh/id_rsa  # File permissions for private key (optional)
     ```

8. **Download the private key (id_rsa) to your Jenkins server**:
   - To allow Jenkins to connect via SSH to the web app EC2 instance, you need the private key (`id_rsa`) on your Jenkins server. 
   - Use **scp** to securely download the private key from the web app EC2 instance to your Jenkins server:
     ```bash
     scp -i /path/to/my-key-pair-2.pem /home/ubuntu/.ssh/id_rsa ubuntu@<jenkins-ec2-ip>:/home/ubuntu/ # Execute this on Web app server
     chmod 600 /home/ubuntu/id_rsa # Execute this on Jenkins server
     ```

   - Ensure the private key is stored securely.

### Step 5: Create a Jenkins Pipeline

1. **Configure SSH Credentials for Web App EC2 in "Publish Over SSH" Plugin**:
   - **Log into Jenkins**:
     - Open a browser and navigate to Jenkins using the public IP of your Jenkins EC2 instance:
       ```
       http://<jenkins-ec2-ip>:8080
       ```
     - Log in to Jenkins with your credentials.

   - Navigate to Manage Jenkins → System.
   - Scroll down to the Publish Over SSH section.
   - Add a new SSH server configuration by specifying:
      - Name (use as "webapp-ssh-credentials", this should match exactly as in the Jenkinsfile).
      - Hostname (the public IP or DNS of the EC2 instance).
      - Username (for SSH access to your EC2 instance).
      - Authentication method (private key or password).
      - Paste your id_rsa file contents from Web App EC2.
   - Save the configuration.

   This *webapp-ssh-credentials* credential will be used by Jenkins server to connect to Web App over SSH connection for deploying application and installing dependencies.

2. **Create Jenkinsfile**:
   - In your [GitHub repository](https://github.com/swapnilyavalkar/dynamicweb-nodeapp), create the `Jenkinsfile` with the following contents to define the pipeline:

```groovy
pipeline {
    agent any
    stages {
        stage('Clone Repository') {
            steps {
                sshPublisher(publishers: [
                    sshPublisherDesc(configName: 'webapp-ssh-credentials', transfers: [
                        sshTransfer(execCommand: '''
                            set -e
                            # Clone the repository into /home/ubuntu/DynamicWeb-NodeApp
                            cd /home/ubuntu
                            if [ ! -d "DynamicWeb-NodeApp" ]; then
                                git clone https://github.com/swapnilyavalkar/dynamicweb-nodeapp.git
                            else
                                cd DynamicWeb-NodeApp
                                git pull origin main
                            fi
                        ''')
                    ])
                ])
            }
        }
        stage('Install Dependencies on EC2') {
            steps {
                sshPublisher(publishers: [
                    sshPublisherDesc(configName: 'webapp-ssh-credentials', transfers: [
                        sshTransfer(execCommand: '''
                            set -e
                            # Install Node.js and npm
                            sudo apt-get update
                            sudo apt-get install -y nodejs npm

                            # Install application dependencies
                            cd /home/ubuntu/DynamicWeb-NodeApp
                            npm install
                        ''')
                    ])
                ])
            }
        }
        stage('Deploy and Start App') {
            steps {
                sshPublisher(publishers: [
                    sshPublisherDesc(configName: 'webapp-ssh-credentials', transfers: [
                        sshTransfer(execCommand: '''
                            set -e
                            # Start the application using nohup and run it in the background
                            cd /home/ubuntu/DynamicWeb-NodeApp
                            nohup node app.js &> app.log &
                        ''')
                    ])
                ])
            }
        }
    }
}
```
     
3. **Create a Jenkins Pipeline**: 
     - From the Jenkins dashboard, click **New Item**.
     - Name the project (e.g., `Deploy-NodeApp-EC2`), select **Pipeline**, and click **OK**.

---

### Final Steps (On Jenkins EC2 Instance):

1. **Trigger the Jenkins Job**:
   - Go back to the Jenkins dashboard, select your pipeline `Deploy-NodeApp-EC2` project, and click **Build Now**.
   - The pipeline will:
     - Clone the code from the GitHub repository.
     - SSH into the Web App EC2 instance.
     - Install dependencies, Deploy the application and run the application in background.

2. **Verify Deployment**:
   - After the build is complete, you can verify the deployment by accessing application using the public IP of your Web App EC2 instance in your browser. (e.g., `http://52.66.239.145:3000/`)

3. **Screenshot**:

   ![Screenshot](./screenshot.png)

---
