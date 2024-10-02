# 01-automated-deployment-codedeploy

AWS CodeDeploy automates code deployments to any instance, including Amazon EC2 instances and instances running on-premises. To deploy your application using AWS CodeDeploy, you need to set up an **Application**, a **Deployment Group**, and configure your EC2 instances accordingly.

### **Prerequisites**

- **AWS Account**: Ensure you have access to an AWS account with the necessary permissions.
- **IAM Roles**: You'll need to create IAM roles for both CodeDeploy and the EC2 instances.
- **EC2 Instances**: Your target EC2 instances must have the CodeDeploy agent installed and be properly tagged.

---

### **Step 1: Create an IAM Role for CodeDeploy**

1. **Navigate to IAM in AWS Console**:
   - Go to the AWS Management Console and navigate to **IAM (Identity and Access Management)**.

2. **Create a Role for AWS CodeDeploy**:
   - Click on **Roles** in the sidebar, then **Create role**.
   - Select **AWS service** as the type of trusted entity.
   - Choose **CodeDeploy** from the list of services.
   - Click **Next: Permissions**.

3. **Attach Policies**:
   - AWS will automatically select the **AWSCodeDeployRole** policy.
   - If not selected, search for **AWSCodeDeployRole** and attach it.
   - Click **Next: Tags** (optional), then **Next: Review**.

4. **Name the Role**:
   - Enter a role name, e.g., `CodeDeployServiceRole`.
   - Click **Create role**.

---

### **Step 2: Create an IAM Role for EC2 Instances**

Your EC2 instances need permissions to interact with AWS services during deployments.

1. **Create a Role for EC2**:
   - In IAM, click **Roles** > **Create role**.
   - Select **AWS service**, then choose **EC2**.
   - Click **Next: Permissions**.

2. **Attach Policies**:
   - Attach the following policies:
     - **AmazonS3ReadOnlyAccess** (Allows EC2 instances to download deployment files from S3).
     - **AWSCodeDeployAgentAccess** (Allows EC2 instances to communicate with CodeDeploy).
   - You can also create a custom policy if needed.

3. **Name the Role**:
   - Enter a role name, e.g., `CodeDeployEC2InstanceRole`.
   - Click **Create role**.

---

### **Step 3: Install the CodeDeploy Agent on EC2 Instances**

The CodeDeploy agent must be installed and running on each EC2 instance you plan to deploy to.

1. **Connect to Your EC2 Instance**:
   - Use SSH to connect to your EC2 instance.

2. **Update the Instance**:
   ```bash
   sudo yum update -y   # For Amazon Linux
   sudo apt-get update  # For Ubuntu
   ```

3. **Download and Install the CodeDeploy Agent**:

   - **For Amazon Linux and Amazon Linux 2**:
     ```bash
     sudo yum install -y ruby wget
     cd /home/ec2-user
     wget https://aws-codedeploy-ap-south-1.s3.ap-south-1.amazonaws.com/latest/install
     sudo chmod +x ./install
     sudo ./install auto
     ```

   - **For Ubuntu**:
     ```bash
     sudo apt-get install -y ruby wget
     cd /home/ubuntu
     wget https://aws-codedeploy-ap-south-1.s3.ap-south-1.amazonaws.com/latest/install
     sudo chmod +x ./install
     sudo ./install auto
     ```

   - **Note**: Replace `ap-south-1` with your AWS region if different.

4. **Verify the Agent is Running**:
   ```bash
   sudo service codedeploy-agent status
   ```

---

### **Step 4: Tag Your EC2 Instances**

CodeDeploy uses tags to identify which instances to deploy to.

1. **Add Tags to Your EC2 Instances**:
   - Go to the EC2 Dashboard.
   - Select your instance.
   - Click on the **Tags** tab, then **Add/Edit Tags**.
   - Add a tag with:
     - **Key**: `CodeDeploy`
     - **Value**: `MyAppInstances` (You can choose any identifier)

---

### **Step 5: Create an S3 Bucket for Deployment Files**

CodeDeploy retrieves the application revision (your zipped application) from an S3 bucket.

1. **Create an S3 Bucket**:
   - Navigate to the S3 service in the AWS Console.
   - Click **Create bucket**.
   - Provide a unique bucket name, e.g., `my-app-deployment-bucket`.
   - Choose the region (must match your deployment region).
   - Adjust settings as needed and click **Create bucket**.

---

### **Step 6: Create an Application in AWS CodeDeploy**

1. **Navigate to AWS CodeDeploy**:
   - Go to the AWS Management Console and select **CodeDeploy** under the **Developer Tools** section.

2. **Create a New Application**:
   - Click **Create application**.
   - Provide an application name, e.g., `MyApp`.
   - In **Compute platform**, select **EC2/On-premises**.
   - Click **Create application**.

---

### **Step 7: Create a Deployment Group**

1. **Create Deployment Group**:
   - In your newly created application, click **Create deployment group**.

2. **Configure Deployment Group Details**:
   - **Deployment group name**: Enter a name, e.g., `MyDeploymentGroup`.
   - **Service role**: Select the IAM role you created earlier (`CodeDeployServiceRole`).

3. **Environment Configuration**:
   - **Amazon EC2 instances**: Select this option.

4. **Specify Instance Tags**:
   - Under **Key**, enter `CodeDeploy`.
   - Under **Value**, enter `MyAppInstances` (or the value you used when tagging your instances).

5. **Deployment Settings**:
   - **Deployment type**: Choose **In-place** (if you want to update the same instances).
   - **Deployment configuration**: You can select `CodeDeployDefault.AllAtOnce` or another strategy depending on your requirements.

6. **Load Balancer** (Optional):
   - If you have a load balancer, you can configure it here.

7. **Advanced Settings**:
   - **Enable CloudWatch alarms** or **SNS notifications** if needed.

8. **Click Create deployment group**.

---

### **Step 8: Prepare the Application for Deployment**

Your application needs an **AppSpec file** (`appspec.yml`) at the root, which tells CodeDeploy how to deploy the application.

1. **Create an AppSpec File**:

   - In your application's root directory, create a file named `appspec.yml`.
   - Example content:
     ```yaml
     version: 0.0
     os: linux
     files:
       - source: /
         destination: /home/ec2-user/myapp
     hooks:
       AfterInstall:
         - location: scripts/install_dependencies.sh
           timeout: 300
           runas: ec2-user
       ApplicationStart:
         - location: scripts/start_server.sh
           timeout: 300
           runas: ec2-user
     ```

   - **Explanation**:
     - **files**: Specifies which files to copy and where.
     - **hooks**: Scripts to run at various stages (e.g., install dependencies, start the server).

2. **Create Hook Scripts**:

   - **scripts/install_dependencies.sh**:
     ```bash
     #!/bin/bash
     cd /home/ec2-user/myapp
     npm install
     ```

   - **scripts/start_server.sh**:
     ```bash
     #!/bin/bash
     cd /home/ec2-user/myapp
     npm start
     ```

   - Ensure these scripts are executable:
     ```bash
     chmod +x scripts/install_dependencies.sh
     chmod +x scripts/start_server.sh
     ```

3. **Include the AppSpec File and Scripts in Your Repository**:
   - Commit and push these files to your GitHub repository so they are included in the deployment package.

---

### **Step 9: Update Jenkins Post-Build Actions**

Now that AWS CodeDeploy is set up, you need to ensure Jenkins knows where to send the deployment package.

1. **Configure AWS Credentials in Jenkins**:

   - In Jenkins, go to **Manage Jenkins** > **Manage Credentials**.
   - Add a new **AWS Credentials** type with access key ID and secret access key that have permissions to S3 and CodeDeploy.

2. **Modify Jenkins Build Steps**:

   - **Post-build Actions**:
     - Add **Publish artifacts to S3 Bucket** (if not already uploading to S3).
       - **S3 Bucket**: `my-app-deployment-bucket`.
       - **Source Files**: `MyApp.zip`. You can clode [dynamicweb-nodeapp](https://github.com/swapnilyavalkar/dynamicweb-nodeapp.git) and download it locally and zip it as MyApp.zip.

        ```bash
        MyApp.zip
        │
        ├── appspec.yml           # Defines deployment instructions for AWS CodeDeploy
        ├── scripts/              # Deployment scripts
        │   ├── install_dependencies.sh
        │   └── start_server.sh
        ├── index.js              # Main Node.js application file
        ├── package.json          # Node.js dependencies and application metadata
        ├── config/               # Any configuration files for the application
        └── public/               # Static files (e.g., images, CSS, JavaScript)
        ```

       - **Destination Directory**: Leave blank or specify a directory.

     - Add **Deploy an application to AWS CodeDeploy**.
       - **Application Name**: `MyApp` (as created in CodeDeploy).
       - **Deployment Group**: `MyDeploymentGroup`.
       - **Revision Location**:
         - **Repository Type**: S3.
         - **Bucket Name**: `my-app-deployment-bucket`.
         - **Bundle Type**: `zip`.
         - **Key**: `MyApp.zip` (or the path if you specified a directory).
       - **AWS Credentials**: Select the credentials you added earlier.
       - **Region**: Your AWS region (e.g., `ap-south-1`).

---

### **Step 10: Trigger a Deployment**

1. **Run the Jenkins Job**:
   - Go back to your Jenkins job and click **Build Now**.
   - Ensure the build completes successfully.

2. **Monitor the Deployment**:

   - Go to the AWS CodeDeploy Console.
   - Navigate to **Deployments** under your application.
   - You should see a new deployment initiated by Jenkins.
   - Click on the deployment to see details and monitor its progress.

3. **Verify on EC2 Instance**:

   - SSH into your EC2 instance.
   - Navigate to `/home/ec2-user/myapp` to see if the files have been deployed.
   - Check if the application is running as expected.

---

### **Additional Notes**

- **Security Groups**: Ensure that the security groups for your EC2 instances allow traffic on the necessary ports (e.g., port 80 for HTTP).
- **EC2 Instance Role**: Your EC2 instances must be using the IAM role `CodeDeployEC2InstanceRole` created earlier.
  - You can attach the role in the **Actions** menu in the EC2 console by selecting **Instance Settings** > **Attach/Replace IAM Role**.
- **CodeDeploy Agent**: Ensure the CodeDeploy agent is running on all target EC2 instances.
  ```bash
  sudo service codedeploy-agent status
  ```
  - To restart the agent:
    ```bash
    sudo service codedeploy-agent restart
    ```
- **Logging**: Deployment logs are stored in `/opt/codedeploy-agent/deployment-root/deployment-logs` on the EC2 instance.
- **Troubleshooting**: If the deployment fails:
  - Check the deployment logs on the EC2 instance.
  - Verify IAM permissions for CodeDeploy and EC2 roles.
  - Ensure the AppSpec file and scripts are correctly formatted and executable.

---

### **Summary**

By following these steps, you've:

- Created IAM roles for CodeDeploy and EC2 instances.
- Installed and configured the CodeDeploy agent on your EC2 instances.
- Tagged your EC2 instances for identification by CodeDeploy.
- Created an S3 bucket to store your deployment artifacts.
- Set up an application and deployment group in AWS CodeDeploy.
- Configured Jenkins to package your application, upload it to S3, and trigger a deployment via CodeDeploy.

This setup allows Jenkins to automatically deploy your application to EC2 instances using AWS CodeDeploy whenever there’s a change in your GitHub repository.
