# 05-automated-microservices-deployment-ecs-cicd

This project will focus on deploying your Node.js web application as a microservice using AWS ECS. It will include containerization, deployment, and setting up a CI/CD pipeline. Here’s a detailed breakdown of the configurations and steps for this project.

---

## **Step 1: Clone Your GitHub Repository**

### Why?
- **Why are we doing this?**  
  Cloning the repository is the first step to getting the source code locally on your system or on any system that will interact with AWS services. The repository contains all the application code that will be containerized and deployed.

### What?
- **What is cloning a repository?**  
  Cloning is copying the entire repository (code, history, and configuration) from GitHub to your local machine. This gives you the ability to modify the code and push changes back to GitHub, which can then trigger the CI/CD pipeline.

### How?
- **How does it work?**  
  Git is a version control system that tracks changes to files in a project. GitHub hosts repositories that you can clone using Git commands.

### Steps to Clone Your Repository:
1. **Open a terminal** on your local machine or the EC2 instance where you will set up the pipeline.
   
2. **Clone the repository**:
   Run the following command to clone your Node.js web application repository:
   ```bash
   git clone https://github.com/swapnilyavalkar/dynamicweb-nodeapp.git
   ```
   
3. **Navigate into the cloned repository**:
   After cloning, go into the project directory:
   ```bash
   cd dynamicweb-nodeapp
   ```

4. **Verify the repository**:
   You can check the repository's content with:
   ```bash
   ls
   ```

---

### **Step 2: Steps to Set Up CI/CD Pipeline**

This will involve using AWS CodePipeline, CodeBuild, and ECS to automatically build and deploy your web application whenever new code is pushed to the GitHub repository.

### Why?
- **Why are we doing this?**  
  Setting up a CI/CD pipeline automates the entire process of building, testing, and deploying the application. This allows for faster, reliable releases with minimal manual intervention, ensuring continuous integration and continuous delivery.

### What?
- **What is CI/CD with AWS CodePipeline?**  
  AWS CodePipeline automates the software release process by integrating with source control (GitHub), building the application with CodeBuild, and deploying the updated application to ECS or another AWS service.

### How?
- **How does it work?**  
  CodePipeline monitors the repository for changes. When a new commit is pushed, the pipeline is triggered, and it runs through the build and deploy stages. AWS CodeBuild is used to build the Docker image, and ECS pulls the new image for deployment.

---

### **Step 2.1: Create an AWS CodePipeline**

1. **Go to the AWS CodePipeline Console**:
   - Open the [AWS CodePipeline Console](https://console.aws.amazon.com/codepipeline).

2. **Create a New Pipeline**:
   - Click **Create Pipeline**.
   - Enter a **Pipeline name**: `my-web-app-pipeline`.
   - Select the **Service Role** option:
     - **Create a new service role**: This will automatically create the necessary IAM role for the pipeline.
   - Click **Next** to move to the next step.

---

### **Step 2.2: Configure the Source Stage (GitHub)**

1. **Select Source Provider**:
   - For **Source Provider**, select **GitHub**.
   - Click **Connect to GitHub** and authorize CodePipeline to access your GitHub account.

2. **Select Repository**:
   - Choose the **Repository**: `dynamicweb-nodeapp`.
   - Select the **Branch** that should trigger the pipeline (e.g., `main`).
   
3. **Output Artifacts**:
   - Keep the default output artifact configuration (this is where the source code will be stored for later stages).

4. **Move to Next Step**:
   - Click **Next** to continue.

---

### **Step 2.3: Configure Build Stage (CodeBuild)**

1. **Select Build Provider**:
   - For **Build Provider**, select **AWS CodeBuild**.

2. **Create a New Build Project**:
   - Click **Create project** to create a new build project in CodeBuild.
   
3. **Build Project Settings**:
   - Enter a **Project name**: `my-web-app-build`.
   - **Environment**:
     - **Managed image**: Select **Ubuntu**.
     - **Runtime**: Select **Standard** and choose the latest **Node.js version** (e.g., Node.js 14).
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
         - $(aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin <aws_account_id>.dkr.ecr.ap-south-1.amazonaws.com)
         - REPOSITORY_URI=<aws_account_id>.dkr.ecr.ap-south-1.amazonaws.com/my-web-app-repo
     build:
       commands:
         - echo Build started on `date`
         - echo Building the Docker image...
         - docker build -t my-web-app .
         - docker tag my-web-app:latest $REPOSITORY_URI:latest
     post_build:
       commands:
         - echo Pushing the Docker image...
         - docker push $REPOSITORY_URI:latest
         - echo Build completed on `date`
   ```

5. **Artifact Type**:
   - Select **No artifacts** (as CodeBuild will push the Docker image directly to ECR).

6. **Finish Creating the Build Project**:
   - Click **Continue to CodePipeline** and select the newly created build project (`my-web-app-build`).

7. **Move to Next Step**:
   - Click **Next**.

---

### **Step 2.4: Configure Deploy Stage (Amazon ECS)**

1. **Deploy Provider**:
   - Select **Deploy Provider** as **Amazon ECS**.

2. **ECS Configuration**:
   - **Cluster name**: Select the ECS cluster you created earlier.
   - **Service name**: Select the ECS service running your web application (e.g., `my-web-app-service`).
   - **Image definitions**: Leave the default configuration (CodePipeline will automatically update the service with the new Docker image).

3. **Move to Next Step**:
   - Click **Next**.

---

### **Step 2.5: Review and Create Pipeline**

1. **Review Configuration**:
   - Review the entire pipeline configuration.
   
2. **Create the Pipeline**:
   - Click **Create pipeline**. CodePipeline will now be set up.

---

### **Step 3: Push Changes to GitHub to Trigger the Pipeline**

1. **Make any changes** to your code (e.g., update the `app.js` file).
2. **Add, commit, and push the changes** to GitHub:
   ```bash
   git add .
   git commit -m "Updated web app"
   git push origin main
   ```

### **Step 4: Monitor the Pipeline Execution**

1. **Go to CodePipeline Console** to see the pipeline execution.
2. As soon as you push changes, the pipeline will start building the Docker image, pushing it to ECR, and deploying it to ECS.