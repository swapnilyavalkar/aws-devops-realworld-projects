# 04-Fargate-Serverless-Container 🚀

---

## **Project Overview**

In this project, you will deploy the application as a containerized microservice using Amazon ECS (Elastic Container Service) on Fargate, leveraging the AWS management console, and using my **Docker Hub image** as the source.

---

## **Steps to Implement the Project:**

### **Step 1: Prerequisites**
Ensure the following prerequisites are met:
- **Docker** is installed locally, and you're familiar with pushing and pulling images from Docker Hub.
- Your **AWS account** is set up, and you have permissions to create resources like ECS clusters and ECR repositories.

### **Step 2: Use Prebuilt Docker Image from Docker Hub**

1. **Pull the Docker image** from Docker Hub:
   ```bash
   docker pull swapnilyavalkar/aws-features-explorer-app:latest
   ```

2. **Run the Docker container locally** to test the app:
   ```bash
   docker run -d -p 80:80 swapnilyavalkar/aws-features-explorer-app:latest
   ```
   - Access the app on `http://localhost` to verify it's working.

### **Step 3: Set Up ECS Cluster**
1. **Open the ECS Console**:
   - Navigate to the **ECS** service in the AWS Management Console.

2. **Create a New ECS Cluster**:
   - Choose **Networking only (Fargate)** and click **Next Step**.
   - Name your cluster (e.g., `AWSFeaturesExplorerCluster`).
   - Configure VPC and subnets as per your setup.
   - Click **Create**.

### **Step 4: Create ECS Task Definition**
1. **Create a New Task Definition**:
   - Choose **Fargate** as the launch type.
   - Click **Create new Task Definition** and name it (e.g., `AWSFeaturesExplorerTask`).

2. **Define Container Settings**:
   - Set up your container configuration:
     - **Container name**: `AWSFeaturesExplorerContainer`
     - **Image**: Use the Docker Hub image `swapnilyavalkar/aws-features-explorer-app:latest`.
     - **Memory**: Choose memory (e.g., 512 MB).
     - **Port mappings**: Set container port to `80` (since Nginx uses port 80 by default).
   - Click **Add**.

3. **Task Role**:
   - Assign a task execution role (e.g., `ecsTaskExecutionRole`) that allows ECS to pull images and send logs to CloudWatch.

4. **Create Task Definition**.

### **Step 5: Create ECS Service**
1. **Create a New Service**:
   - Go to the **Services** tab in the ECS Console.
   - Click **Create**.
   - Select the task definition created earlier (`AWSFeaturesExplorerTask`).
   - Choose **Fargate** as the launch type.
   - Set the number of tasks to **1**.

2. **VPC and Networking**:
   - Choose the appropriate VPC and subnets where the service will run.
   - Enable **Auto-assign public IP** if your service needs to be publicly accessible.

3. **Load Balancer (Optional)**:
   - If you need to expose the service publicly, you can configure an **Application Load Balancer (ALB)** to route traffic to the ECS service.
   - Attach an ALB and create a target group for port **80**.

4. **Service Scaling** (Optional):
   - Set up auto-scaling if needed.
   - Click **Create Service**.

### **Step 6: Test the Service**
1. **Retrieve the Public IP**:
   - If your service is exposed publicly, navigate to the **Tasks** tab, select the running task, and copy the **public IP**.

2. **Access the Application**:
   - Open the browser and access `http://<public-ip>`.
   - The **AWS Features Explorer App** should be running with Nginx.

### **Step 7: Enable CloudWatch Logging**
1. Ensure CloudWatch logs are enabled in the **task definition**.
2. Go to the **CloudWatch Console** to verify the logs from the container.

### **Step 8: Clean Up Resources (Optional)**
1. After the project is complete, clean up the resources to avoid unnecessary charges:
   - Delete the ECS service and cluster.
   - Remove any unused VPC resources and subnets.

---

## **Summary of Key Concepts**:
- **Amazon ECS**: Container orchestration service that allows you to run microservices.
- **Docker Hub**: A cloud-based repository where you store Docker images.
- **Fargate**: A serverless compute engine for containers.
- **Nginx**: A web server used for serving content within the Docker container.
- **CloudWatch**: Monitoring and logging service to collect logs and metrics from ECS tasks.