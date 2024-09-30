# **06-ECS-BlueGreen-Deployment 🚀**

---

## **Overview**

- **What we are doing**:  
  We are deploying the **AWS Features Explorer App** from your GitHub repository as a containerized microservice using **Amazon ECS** (Elastic Container Service) on **Fargate** with a **Blue/Green deployment strategy**. This project will involve containerization, Docker image creation, deploying the app using ECS, setting up an Application Load Balancer (ALB), and configuring a CI/CD pipeline with **AWS CodePipeline**, **CodeBuild**, and **CodeDeploy** to automate Blue/Green deployments.

- **Why we are doing it**:  
  Implementing a **Blue/Green deployment** strategy minimizes downtime and risk by running two identical production environments (Blue and Green). This allows seamless switching between environments during deployments, ensuring zero downtime and easy rollback in case of issues. It enhances the reliability, availability, and scalability of your application.

- **Real-Life Use Case**:  
  Companies like **Etsy** and **Amazon** use Blue/Green deployments to deliver new features and updates without affecting the user experience. This approach enables continuous delivery and deployment, ensuring that applications are always up-to-date while maintaining high availability.

---

## **Tools and Technologies**

- **AWS ECS (Fargate)**: For serverless container orchestration.
- **Docker**: For containerizing the application.
- **AWS ECR (Elastic Container Registry)**: To store the Docker image.
- **AWS CodePipeline**: For automating the CI/CD pipeline.
- **AWS CodeBuild**: For building the Docker image.
- **AWS CodeDeploy**: For managing Blue/Green deployments on ECS.
- **AWS Application Load Balancer (ALB)**: For routing traffic between Blue and Green environments.
- **GitHub**: To store and manage the application's source code.

---

## **Steps to Implement the Project**

---

### **Step 1: Clone the Repository and Build the Docker Image**

1. **Clone the repository**:
   - Open a terminal and run:
     ```bash
     git clone https://github.com/swapnilyavalkar/aws-features-explorer-app.git
     ```

2. **Navigate into the project directory**:
   ```bash
   cd aws-features-explorer-app
   ```

3. **Create the `Dockerfile`**:  
   In the root of the project directory, create a `Dockerfile` to define how the Docker image will be built.

   Example `Dockerfile`:
   ```Dockerfile
   FROM nginx:alpine
   COPY . /usr/share/nginx/html
   EXPOSE 80
   CMD ["nginx", "-g", "daemon off;"]
   ```

4. **Build the Docker image**:  
   Build the Docker image using the following command:
   ```bash
   docker build -t aws-features-explorer-app .
   ```

5. **Test the Docker image locally**:  
   Run the Docker container to ensure everything works as expected:
   ```bash
   docker run -d -p 80:80 aws-features-explorer-app
   ```
   - Access the application on `http://localhost` to verify it's working.

---

### **Step 2: Push Docker Image to Amazon ECR (Elastic Container Registry)**

1. **Create an ECR repository**:
   - Go to the [Amazon ECR Console](https://console.aws.amazon.com/ecr).
   - Click **Create Repository** and name it `aws-features-explorer-app-repo`.

2. **Authenticate Docker with ECR**:  
   Run the following command to authenticate Docker with ECR:
   ```bash
   aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <aws_account_id>.dkr.ecr.<region>.amazonaws.com
   ```
   Replace `<region>` with your AWS region (e.g., `us-east-1`) and `<aws_account_id>` with your AWS account ID.

3. **Tag the Docker image**:  
   Tag your Docker image to prepare it for pushing to ECR:
   ```bash
   docker tag aws-features-explorer-app:latest <aws_account_id>.dkr.ecr.<region>.amazonaws.com/aws-features-explorer-app-repo:latest
   ```

4. **Push the image to ECR**:  
   Push the Docker image to your ECR repository:
   ```bash
   docker push <aws_account_id>.dkr.ecr.<region>.amazonaws.com/aws-features-explorer-app-repo:latest
   ```

---

### **Step 3: Create an Application Load Balancer (ALB)**

1. **Navigate to the EC2 Console**:
   - Go to the [EC2 Console](https://console.aws.amazon.com/ec2/).
   - In the left navigation pane, under **Load Balancing**, click **Load Balancers**.

2. **Create a New Load Balancer**:
   - Click **Create Load Balancer**.
   - Choose **Application Load Balancer**.

3. **Configure the Load Balancer**:
   - **Name**: `aws-features-explorer-alb`.
   - **Scheme**: Internet-facing.
   - **Listeners**: Ensure there is a listener on port 80.
   - **Availability Zones**: Select the VPC and subnets where your ECS tasks will run.

4. **Configure Security Groups**:
   - Assign a security group that allows inbound traffic on port 80.

5. **Configure Routing**:
   - **Target Group**: Create a new target group.
   - **Name**: `aws-features-explorer-tg`.
   - **Target Type**: IP.

6. **Register Targets**:
   - You can skip registering targets for now, as ECS will automatically register the tasks.

7. **Review and Create**:
   - Review all settings and click **Create**.

---

### **Step 4: Deploy Application on AWS ECS Using Fargate with Blue/Green Deployment**

1. **Create a New ECS Cluster**:
   - Go to the [ECS Console](https://console.aws.amazon.com/ecs).
   - Click **Clusters** in the navigation pane.
   - Click **Create Cluster**.
   - Choose **Networking only** for **Fargate**.
   - **Cluster name**: `aws-features-explorer-cluster`.
   - Click **Create**.

2. **Create a Task Execution Role**:
   - Go to the [IAM Console](https://console.aws.amazon.com/iam/).
   - Click **Roles** and then **Create role**.
   - Select **AWS Service** > **Elastic Container Service** > **Elastic Container Service Task**.
   - Attach the following policies:
     - **AmazonECSTaskExecutionRolePolicy**
     - **AWSCodeDeployRoleForECS**
   - **Role name**: `ecsTaskExecutionRole`.
   - Click **Create role**.

3. **Create a Task Definition**:
   - In the ECS Console, click **Task Definitions**.
   - Click **Create new Task Definition** and select **Fargate**.
   - **Task Definition Name**: `aws-features-explorer-task`.
   - **Task Role**: Leave as **None**.
   - **Network Mode**: `awsvpc`.
   - **Task Execution Role**: Select `ecsTaskExecutionRole`.
   - **Container Definitions**:
     - Click **Add container**.
     - **Container name**: `aws-features-explorer-container`.
     - **Image**: `<aws_account_id>.dkr.ecr.<region>.amazonaws.com/aws-features-explorer-app-repo:latest`.
     - **Port mappings**: Container port `80`.
     - Click **Add**.
   - Click **Create**.

4. **Create an ECS Service with Blue/Green Deployment**:
   - In the ECS Console, click **Clusters** and select `aws-features-explorer-cluster`.
   - Click **Services** tab and then **Create**.
   - **Launch Type**: `Fargate`.
   - **Task Definition**: Select `aws-features-explorer-task`.
   - **Service Name**: `aws-features-explorer-service`.
   - **Number of Tasks**: `1`.
   - **Deployment Type**: Select **Blue/Green deployment (powered by AWS CodeDeploy)**.
   - **Load Balancer Type**: Select **Application Load Balancer**.
   - **Load Balancer Name**: Select `aws-features-explorer-alb`.
   - **Production Listener Port**: `80:HTTP`.
   - **Target Group Name**:
     - **Production**: Select `aws-features-explorer-tg`.
     - **Test**: Create a new target group or select an existing one for the test environment.
   - **Auto-assign Public IP**: `ENABLED`.
   - **VPC and Subnets**: Select the same VPC and subnets used for the ALB.
   - **Security Groups**: Use the same security group that allows traffic on port 80.
   - Click **Next step** and **Create Service**.

---

### **Step 5: Set Up CI/CD Pipeline with AWS CodePipeline and CodeDeploy**

#### **Step 5.1: Create an AWS CodePipeline**

1. **Go to the AWS CodePipeline Console**:
   - Open the [AWS CodePipeline Console](https://console.aws.amazon.com/codepipeline).

2. **Create a New Pipeline**:
   - Click **Create Pipeline**.
   - **Pipeline name**: `aws-features-explorer-pipeline`.
   - **Service Role**:
     - Choose **New service role**.
     - Role name: `AWSCodePipelineServiceRole`.
   - Click **Next**.

---

#### **Step 5.2: Configure the Source Stage (GitHub)**

1. **Select Source Provider**:
   - For **Source Provider**, select **GitHub Version 2**.
   - Click **Connect to GitHub**, and authorize access.

2. **Select Repository**:
   - **Repository**: `swapnilyavalkar/aws-features-explorer-app`.
   - **Branch**: `main`.

3. **Change Detection**:
   - Choose **GitHub Webhook** to trigger the pipeline on code changes.

4. **Click Next**.

---

#### **Step 5.3: Configure Build Stage (CodeBuild)**

1. **Select Build Provider**:
   - For **Build Provider**, select **AWS CodeBuild**.

2. **Create a New Build Project**:
   - Click **Create project**.

3. **Project Configuration**:
   - **Project Name**: `aws-features-explorer-build`.
   - **Environment**:
     - **Managed image**:
       - Operating system: **Ubuntu**.
       - Runtime(s): **Standard**.
       - Image: `aws/codebuild/standard:5.0` or latest.
     - **Service role**:
       - Choose **New service role**.
       - Role name: `codebuild-aws-features-explorer-service-role`.
   - **Buildspec**:
     - Use a buildspec file.

4. **Create `buildspec.yml`**:  
   In the root of your repository, create a `buildspec.yml` file:

   ```yaml
   version: 0.2

   phases:
     pre_build:
       commands:
         - echo Logging in to Amazon ECR...
         - $(aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <aws_account_id>.dkr.ecr.<region>.amazonaws.com)
         - REPOSITORY_URI=<aws_account_id>.dkr.ecr.<region>.amazonaws.com/aws-features-explorer-app-repo
         - COMMIT_HASH=$(echo $CODEBUILD_RESOLVED_SOURCE_VERSION | cut -c 1-7)
         - IMAGE_TAG=${COMMIT_HASH:=latest}
     build:
       commands:
         - echo Build started on `date`
         - echo Building the Docker image...
         - docker build -t $REPOSITORY_URI:$IMAGE_TAG .
     post_build:
       commands:
         - echo Pushing the Docker image...
         - docker push $REPOSITORY_URI:$IMAGE_TAG
         - echo Writing image definitions file...
         - printf '[{"name":"aws-features-explorer-container","imageUri":"%s"}]' $REPOSITORY_URI:$IMAGE_TAG > imagedefinitions.json
   artifacts:
     files: imagedefinitions.json
   ```

   Replace `<region>` and `<aws_account_id>` with your AWS region and account ID.

5. **Artifacts**:
   - **Type**: **Amazon S3**.
   - **Bucket name**: Create a new S3 bucket or select an existing one.
   - **Name**: Leave default or specify.

6. **Save Build Project**:
   - Click **Continue to CodePipeline**.

---

#### **Step 5.4: Configure Deploy Stage (AWS CodeDeploy)**

1. **Deploy Provider**:
   - Select **AWS CodeDeploy**.

2. **Application Name**:
   - Create a new CodeDeploy application:
     - **Application name**: `aws-features-explorer-codedeploy-app`.
     - **Compute Platform**: **Amazon ECS**.

3. **Deployment Group**:
   - **Deployment group name**: `aws-features-explorer-deployment-group`.
   - **Service Role**:
     - Create a new IAM role with the policy **AWSCodeDeployRoleForECS**.
   - **Cluster name**: `aws-features-explorer-cluster`.
   - **Service name**: `aws-features-explorer-service`.

4. **Load Balancer Configuration**:
   - **Production Listener ARN**: Select the ALB listener on port 80.
   - **Target Groups**:
     - **Prod Target Group**: Select the production target group.
     - **Test Target Group**: Select the test target group.

5. **Traffic Shifting**:
   - **Deployment configuration**: Choose **CodeDeployDefault.ECSAllAtOnce** or customize as needed.

6. **Click Next**.

---

#### **Step 5.5: Review and Create Pipeline**

1. **Review Configuration**:
   - Ensure all stages are correctly configured.

2. **Create the Pipeline**:
   - Click **Create pipeline**.

---

### **Step 6: Push Changes to GitHub to Trigger the Pipeline**

1. **Commit and Push Changes**:
   - Ensure the `buildspec.yml` and `Dockerfile` are added to your repository.
   - Add, commit, and push the changes to GitHub:
     ```bash
     git add .
     git commit -m "Added buildspec.yml and Dockerfile for CI/CD pipeline"
     git push origin main
     ```

---

### **Step 7: Monitor the Pipeline Execution and Deployment**

1. **Monitor CodePipeline**:
   - Go to the [AWS CodePipeline Console](https://console.aws.amazon.com/codepipeline).
   - Select your pipeline `aws-features-explorer-pipeline` to view its progress.

2. **Monitor CodeBuild**:
   - In case of build failures, check the logs in [AWS CodeBuild Console](https://console.aws.amazon.com/codebuild).

3. **Monitor CodeDeploy**:
   - Check deployment status in the [AWS CodeDeploy Console](https://console.aws.amazon.com/codedeploy).

4. **Verify the Application**:
   - Once deployment is successful, access the application via the ALB DNS name.
   - Find the ALB DNS name in the EC2 Console under Load Balancers.

5. **Test Blue/Green Deployment**:
   - Make a change in the application (e.g., update `index.html`).
   - Commit and push the changes to GitHub.
   - The pipeline will trigger, and CodeDeploy will perform a Blue/Green deployment.
   - Monitor the deployment process and verify that the new version is live without downtime.

---

**Congratulations!** You have successfully implemented a Blue/Green deployment for your application using AWS ECS, CodePipeline, CodeBuild, and CodeDeploy.