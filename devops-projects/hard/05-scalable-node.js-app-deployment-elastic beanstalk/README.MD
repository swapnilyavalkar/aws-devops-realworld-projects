# 05-scalable-node.js-app-deployment-elastic beanstalk

#### Prerequisites:
- AWS account set up.
- Node.js web application repository (you can use the one from my GitHub: [dynamicweb-nodeapp](https://github.com/swapnilyavalkar/dynamicweb-nodeapp.git)).
- AWS CLI installed and configured.

#### Steps:

1. **Install Elastic Beanstalk CLI** (If you don't have it already installed):
   - Install using pip:
     ```bash
     pip install awsebcli --upgrade
     ```

2. **Initialize Elastic Beanstalk Application**:
   - Navigate to your application folder (the folder containing your `package.json`).
   - Run the following command to initialize Elastic Beanstalk:
     ```bash
     eb init
     ```
   - Follow the prompts to:
     - Select your AWS region (e.g., `ap-south-1`).
     - Choose the platform (select `Node.js`).
     - Configure SSH (optional but recommended).

3. **Create and Deploy the Application**:
   - Create the Elastic Beanstalk environment and deploy your application:
     ```bash
     eb create <environment-name>
     ```
   - Elastic Beanstalk will now create an environment for your application. Once the environment is ready, you can deploy the application by running:
     ```bash
     eb deploy
     ```

4. **Access Your Application**:
   - After deployment, run the following command to open the application in your browser:
     ```bash
     eb open
     ```

5. **Monitor and Update**:
   - You can check the health and logs of your Elastic Beanstalk environment with:
     ```bash
     eb status
     eb logs
     ```

#### Summary of Why Elastic Beanstalk:
- **Elastic Beanstalk** simplifies application deployment by managing infrastructure, scaling, and updates.
- It provides a fully managed environment, allowing you to focus more on your application code than infrastructure management.
- Integrated monitoring and scaling features make it easy to ensure your application is highly available.

---

Once you deploy your Node.js application using **Elastic Beanstalk**, it will be hosted on AWS infrastructure, not on your local system. Here's what happens and how you can access it:

### Accessing Your Application:

1. **AWS Elastic Beanstalk URL**:
   - After successful deployment, AWS Elastic Beanstalk assigns a public URL to your application. You can access this URL to view and interact with your application.
   - You can obtain this URL by running the following command after deployment:
     ```bash
     eb open
     ```
     This command will automatically open your application in the default web browser.
   - The URL will typically look something like: `http://<environment-name>.<region>.elasticbeanstalk.com/`.

2. **AWS Management Console**:
   - You can also access your application from the AWS Management Console:
     - Go to the **Elastic Beanstalk** section.
     - Navigate to your environment, and in the environment dashboard, you'll see the application URL.

### Where Is Your Application Deployed?

- **AWS Platform**:
  - Your application is hosted on AWS, specifically on EC2 instances managed by Elastic Beanstalk.
  - AWS handles the provisioning of infrastructure (like servers, load balancers, and auto-scaling) for your application.

### What Elastic Beanstalk Manages:
- Elastic Beanstalk abstracts away the details of the underlying infrastructure, which includes:
  - **EC2 instances**: Where your application runs.
  - **Load balancing**: To distribute traffic across multiple instances if your application scales.
  - **Auto-scaling**: Elastic Beanstalk can automatically scale the number of instances based on traffic.
  - **Monitoring**: Integrated monitoring with CloudWatch to track the health and performance of your application.

---

To clean up your **Elastic Beanstalk environment** and all its created resources, follow these steps. This will ensure that no unnecessary charges are incurred from the resources used.

### Step-by-Step Cleanup Process for Elastic Beanstalk Environment:

1. **Delete the Elastic Beanstalk Environment**:
   - Run the following command in the directory where your **Elastic Beanstalk** project is initialized:
     ```bash
     eb terminate <environment-name>
     ```
   - This command will delete the environment and all associated AWS resources (like EC2 instances, load balancers, and auto-scaling groups).
   - You’ll be prompted to confirm this action.

   Example:
   ```bash
   eb terminate my-environment-name
   ```

2. **Verify Environment Deletion**:
   - After terminating the environment, AWS will begin deleting the resources associated with it. You can check the progress by running:
     ```bash
     eb status
     ```
   - Once the environment is deleted, this command will show that the environment no longer exists.

3. **Delete the Elastic Beanstalk Application (Optional)**:
   - If you no longer need the entire application (not just the environment), you can delete the application by running:
     ```bash
     eb delete <application-name>
     ```
   - This deletes the application along with all associated environments.

4. **Check and Delete Associated AWS Resources**:
   While terminating the environment cleans up most resources, some might still remain. Verify and delete these resources manually:
   - **S3 Buckets**: Elastic Beanstalk creates S3 buckets for storing logs and configuration files.
     - Go to the **S3 Console**.
     - Identify and delete the buckets created by Elastic Beanstalk (they are usually named with `elasticbeanstalk` in the name).
   - **EC2 Key Pairs**: If you created key pairs for accessing EC2 instances, you can delete them in the **EC2 Console** under **Key Pairs**.
   - **Security Groups**: Check the **EC2 Console** under **Security Groups** for any groups created by Elastic Beanstalk and delete them if no longer in use.
   - **Elastic Load Balancers (ELB)**: Elastic Beanstalk environments with load balancing will create load balancers. Verify if they have been deleted under the **EC2 Console** → **Load Balancers**.
   - **RDS Instances** (if used): If your application created an RDS instance, ensure that it is properly terminated to avoid ongoing charges.

5. **Check CloudFormation Stacks**:
   - Elastic Beanstalk uses **CloudFormation** behind the scenes to manage resources. Sometimes, the stack may remain after deletion.
   - Go to the **CloudFormation Console**, and delete any remaining stacks associated with your environment.

### Optional Script for Cleanup:
You can automate part of this cleanup using AWS CLI commands. Here’s an example to delete the environment and clean up S3:

```bash
# Terminate Elastic Beanstalk environment
eb terminate <environment-name> --all

# List and delete S3 buckets created by Elastic Beanstalk
aws s3 ls | grep elasticbeanstalk
aws s3 rb s3://<bucket-name> --force
```
