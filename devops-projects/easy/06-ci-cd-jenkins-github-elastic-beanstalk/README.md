# 06-ci-cd-jenkins-github-elastic-beanstalk

## Prerequisites:
- Jenkins installed and running (you can use a Jenkins EC2 instance or a local Jenkins setup).
- AWS account and Elastic Beanstalk environment. (You can use envirionment from aws-devops-realworld-projects\devops-projects\hard\05-scalable-node.js-app-deployment-elastic beanstalk)
- Access to your GitHub repository with your Node.js web application.
- AWS CLI configured on your Jenkins server.
  
### Step-by-Step Guide:

#### Step 1: **Install Jenkins and Required Plugins**

1. **Install Jenkins**:
   If you haven’t installed Jenkins, follow the [official Jenkins documentation](https://www.jenkins.io/doc/book/installing/) to install Jenkins on your desired platform.

2. **Install AWS Elastic Beanstalk CLI on Jenkins Server**:
   - On your Jenkins server, install the **AWS Elastic Beanstalk CLI** using:
     ```bash
     pip install awsebcli --upgrade
     ```
   - Make sure you have the AWS CLI installed and configured as well.

3. **Install Jenkins Plugins**:
   - Go to Jenkins dashboard → **Manage Jenkins** → **Manage Plugins**.
   - Search for and install the following plugins:
     - **Git Plugin** (for pulling code from your GitHub repository).
     - **Pipeline Plugin** (for writing Jenkins pipelines).
     - **AWS Elastic Beanstalk Deployment Plugin** (for deploying to Elastic Beanstalk).

#### Step 2: **Create a Jenkins Pipeline Job**

1. **Create a New Job**:
   - In Jenkins, click **New Item**.
   - Name your job (e.g., "NodeJS-CI-CD").
   - Select **Pipeline** as the job type and click **OK**.

2. **Configure the Pipeline Job**:
   - Under the **Pipeline** section, you’ll configure Jenkins to pull your Node.js application from GitHub, build it, and deploy it to Elastic Beanstalk.

3. **Jenkinsfile**:
   You’ll define your CI/CD process in a `Jenkinsfile`, which will automate the steps for:
   - Pulling the latest code from GitHub.
   - Building the Node.js application.
   - Deploying it to AWS Elastic Beanstalk.

   Here’s a sample `Jenkinsfile` for your pipeline:

   ```groovy
   pipeline {
       agent any
       
       environment {
           AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')
           AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
           AWS_REGION = 'ap-south-1'
           EB_ENV = 'my-environment-name'
           EB_APP = 'my-application-name'
       }
       
       stages {
           stage('Checkout Code') {
               steps {
                   git 'https://github.com/swapnilyavalkar/dynamicweb-nodeapp.git'
               }
           }
           
           stage('Install Dependencies') {
               steps {
                   sh 'npm install express'
               }
           }
           
           stage('Run Tests') {
               steps {
                   sh 'npm test' // Optional: only if you have tests
               }
           }
           
           stage('Deploy to Elastic Beanstalk') {
               steps {
                   sh '''
                   eb init -p node.js $EB_APP --region $AWS_REGION
                   eb use $EB_ENV
                   eb deploy
                   '''
               }
           }
       }
       
       post {
           success {
               echo 'Deployment successful!'
           }
           failure {
               echo 'Deployment failed.'
           }
       }
   }
   ```

   Replace the following placeholders with actual values:
   - `aws-access-key-id` and `aws-secret-access-key`: Store your AWS credentials in Jenkins using **Manage Credentials**.
   - `my-environment-name`: Your Elastic Beanstalk environment name.
   - `my-application-name`: Your Elastic Beanstalk application name.

#### Step 3: **Set Up Webhooks on GitHub for Continuous Deployment**

1. **Enable Webhooks** in your GitHub repository to trigger the Jenkins pipeline when changes are pushed to the repository:
   - Go to your GitHub repository → **Settings** → **Webhooks**.
   - Add a webhook with the URL of your Jenkins server:
     ```
     http://<your-jenkins-server>:8080/github-webhook/
     ```
   - Set the content type to `application/json`.

2. **Configure Jenkins Job to Trigger on Git Push**:
   - In your Jenkins job configuration, under **Build Triggers**, enable **GitHub hook trigger for GITScm polling**.

#### Step 4: **Test the CI/CD Pipeline**

1. **Push Code Changes**:
   - Make a small change in your GitHub repository and push it.
   - This should automatically trigger the Jenkins pipeline, build the Node.js app, and deploy it to Elastic Beanstalk.

2. **Monitor the Pipeline**:
   - Go to the Jenkins job and monitor the pipeline stages. You should see logs for each stage (checkout, install dependencies, run tests, deploy).

3. **Verify Deployment**:
   - After a successful pipeline run, visit your Elastic Beanstalk environment URL to verify that the latest version of your Node.js app is deployed.

### Why Jenkins for CI/CD?

- **Automation**: Jenkins automates the entire deployment process, ensuring that new changes in code are deployed without manual intervention.
- **Continuous Integration**: It ensures that every change is tested and validated before deployment.
- **Elastic Beanstalk Integration**: Jenkins can seamlessly deploy applications to AWS services like Elastic Beanstalk, reducing deployment complexity.
- **Scalability**: As your team grows, Jenkins can handle multiple pipelines, allowing several developers to work on features in parallel.
