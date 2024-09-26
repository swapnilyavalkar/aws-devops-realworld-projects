# **05-Microservices-ECS 🚀**

---

## **Overview**

- **What we are doing**:  
  We are deploying the **AWS Features Explorer App** from your GitHub repository as a containerized microservice using **Amazon ECS** (Elastic Container Service) on **Fargate**. This project will include containerization, Docker image creation, deploying the app, and setting up a CI/CD pipeline using AWS services.

- **Why we are doing it**:  
  Using **AWS ECS with Fargate** allows you to run containers without managing the underlying infrastructure. This reduces operational overhead and helps you focus on deploying and scaling your application. The CI/CD pipeline automates the entire deployment process, ensuring faster and more reliable releases.

- **Real-Life Use Case**:  
  Companies like **Netflix** use containerization and AWS ECS to run microservices at scale. These microservices power various features such as video streaming, recommendation systems, and user profiles. By automating deployment with CI/CD pipelines, companies can push updates seamlessly while ensuring high availability and scalability.

---

## **Tools and Technologies**

- **AWS ECS (Fargate)**: For serverless container orchestration.
- **Docker**: For containerizing the application.
- **AWS ECR (Elastic Container Registry)**: To store the Docker image.
- **AWS CodePipeline**: For automating the CI/CD pipeline.
- **GitHub**: To store and manage the application's source code.

---

## **Steps to Implement the Project**

---

### **Step 1: Clone the Repository and Build the Docker Image**

1. **Clone the repository**:
   - Open a terminal and run:
     ```bash
     git clone https://github.com/swapnilyavalkar/AWS-Features-Explorer-App.git
     ```

2. **Navigate into the project directory**:
   ```bash
   cd AWS-Features-Explorer-App
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

### **Step 3: Deploy Application on AWS ECS Using Fargate**

1. **Create a new ECS Cluster**:
   - Go to the [ECS Console](https://console.aws.amazon.com/ecs).
   - Click **Create Cluster**.
   - Select **Networking only (Fargate)** and configure your cluster.

2. **Create a Task Definition**:
   - Go to the ECS Console and click **Task Definitions**.
   - Click **Create new task definition** and select **Fargate**.
   - Configure the task definition:
     - **Container name**: `aws-features-explorer-container`
     - **Image URI**: `<aws_account_id>.dkr.ecr.<region>.amazonaws.com/aws-features-explorer-app-repo:latest`
     - **Port mapping**: 80

3. **Create an ECS Service**:
   - In the ECS console, click **Services** and create a new service.
   - Select the cluster, task definition, and the number of tasks (e.g., 1 task).
   - Configure networking by selecting a VPC, subnets, and security groups (allow traffic on port 80).

4. **Deploy the service**:  
   Once the service is created, ECS will automatically deploy the tasks based on the configuration.

---

### **Step 4: Set Up CI/CD Pipeline with AWS CodePipeline**

#### **Step 4.1: Create an AWS CodePipeline**

1. **Go to the AWS CodePipeline Console**:
   - Open the [AWS CodePipeline Console](https://console.aws.amazon.com/codepipeline).

2. **Create a New Pipeline**:
   - Click **Create Pipeline**.
   - Enter a **Pipeline name**: `my-web-app-pipeline`.
   - Select the **Service Role** option:
     - **Create a new service role**: This will automatically create the necessary IAM role for the pipeline.
   - Click **Next** to move to the next step.

---

#### **Step 4.2: Configure the Source Stage (GitHub)**

1. **Select Source Provider**:
   - For **Source Provider**, select **GitHub**.
   - Click **Connect to GitHub** and authorize CodePipeline to access your GitHub account.

2. **Select Repository**:
   - Choose the **Repository**: `AWS-Features-Explorer-App`.
   - Select the **Branch** that should trigger the pipeline (e.g., `main`).

3. **Output Artifacts**:
   - Keep the default output artifact configuration (this is where the source code will be stored for later stages).

4. **Move to Next Step**:
   - Click **Next** to continue.

---

#### **Step 4.3: Configure Build Stage (CodeBuild)**

1. **Select Build Provider**:
   - For **Build Provider**, select **AWS CodeBuild**.

2. **Create a New Build Project**:
   - Click **Create project** to create a new build project in CodeBuild.

3. **Build Project Settings**:
   - Enter a **Project name**: `aws-features-explorer-build`.
   - **Environment**:
     - **Managed image**: Select **Ubuntu**.
     - **Runtime**: Select **Standard**.
     - **Image**: Use the latest Docker image (`aws/codebuild/standard:5.0` or newer).
     - **Build specifications**: Instruct CodeBuild on how to build the Docker image using a `buildspec.yml` file.

4. **Create buildspec.yml**:  
   In the root of your repository, create a file called `buildspec.yml`. This file contains instructions for CodeBuild to build your Docker image and push it to Amazon ECR.

   Example `buildspec.yml`:
   ```yaml
   version: 0.2

   phases:
     pre_build:
       commands:
         - echo Logging in to Amazon ECR...
         - $(aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <aws_account_id>.dkr.ecr.<region>.amazonaws.com)
         - REPOSITORY_URI=<aws_account_id>.dkr.ecr.<region>.amazonaws.com/aws-features-explorer-app-repo
     build:
       commands:
         - echo Build started on `date`
         - echo Building the Docker image...
         - docker build -t aws-features-explorer-app .
         - docker tag aws-features-explorer-app:latest $REPOSITORY_URI:latest
     post_build:
       commands:
         - echo Pushing the Docker image...
         - docker push $REPOSITORY_URI:latest
         - echo Build completed on `date`
   ```

5. **Artifact Type**:
   - Select **No artifacts** (as CodeBuild will push the Docker image directly to ECR).

6. **Finish Creating the Build Project**:
   - Click **Continue to CodePipeline** and select the newly created build project (`aws-features

-explorer-build`).

7. **Move to Next Step**:
   - Click **Next**.

---

#### **Step 4.4: Configure Deploy Stage (Amazon ECS)**

1. **Deploy Provider**:
   - Select **Deploy Provider** as **Amazon ECS**.

2. **ECS Configuration**:
   - **Cluster name**: Select the ECS cluster you created earlier.
   - **Service name**: Select the ECS service running your web application (e.g., `aws-features-explorer-service`).
   - **Image definitions**: Leave the default configuration (CodePipeline will automatically update the service with the new Docker image).

3. **Move to Next Step**:
   - Click **Next**.

---

#### **Step 4.5: Review and Create Pipeline**

1. **Review Configuration**:
   - Review the entire pipeline configuration.

2. **Create the Pipeline**:
   - Click **Create pipeline**. CodePipeline will now be set up.

---

### **Step 5: Push Changes to GitHub to Trigger the Pipeline**

1. **Make any changes** to your code (e.g., update the `index.html` file).
2. **Add, commit, and push the changes** to GitHub:
   ```bash
   git add .
   git commit -m "Updated AWS Features Explorer Index.html"
   git push origin main
   ```

---

### **Step 6: Monitor the Pipeline Execution**

1. **Go to the CodePipeline Console** to see the pipeline execution.
2. As soon as you push changes, the pipeline will start building the Docker image, pushing it to ECR, and deploying it to ECS.