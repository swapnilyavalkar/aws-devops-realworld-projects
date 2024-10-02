# 02-containerized-microservices-ecs

## Prerequisites:
1. **AWS CLI Installed**: Make sure AWS CLI is installed and configured on your machine.
2. **Docker Installed**: Ensure Docker is installed for containerizing my dynamicweb-nodeapp Node.js app.
3. **AWS IAM Role for ECS**: Create an IAM role with the necessary permissions for ECS tasks, ECR, and CloudWatch.

---

## Instructions:

### Step 1: Dockerize my dynamicweb-nodeapp Node.js Web App

1. **Clone your repository locally:**
   ```bash
   git clone https://github.com/swapnilyavalkar/dynamicweb-nodeapp.git
   cd dynamicweb-nodeapp
   ```

2. **Create a Dockerfile** inside your Node.js app directory if not already created. This will define how your application is containerized:
   ```Dockerfile
   # Use an official Node.js runtime as a parent image
   FROM node:14

   # Set the working directory inside the container
   WORKDIR /usr/src/app
   
   # Copy package.json and package-lock.json into the working directory
   COPY ./package*.json ./
   
   # Install app dependencies
   RUN npm install
   
   # Copy the entire web app directory except for files in .dockerignore
   COPY . .
   
   # Expose the port your app runs on (e.g., 8080)
   EXPOSE 3000
   
   # Command to start the application
   CMD ["npm", "start"]
   ```

3. **Build the Docker image**:
   ```bash
   docker build -t my-nodejs-web-app .
   ```

4. **Test the Docker image locally** (optional):
   ```bash
   docker run -p 80:3000 my-nodejs-web-app
   # After executing above command, open URL on your system http://localhost and you should see the homepage of this web-app. Here, we are forwarding local traffic on port 80 to port 3000 in the container.
   ```

---

### Step 2: Push the Docker Image to Amazon ECR

1. **Create an ECR repository**:
   - Go to the AWS Management Console, search for **ECR**, and create a new repository called `my-nodejs-web-app`.
   
   Alternatively, you can use the AWS CLI:
   ```bash
   aws ecr create-repository --repository-name my-nodejs-web-app
   ```

2. **Authenticate Docker to ECR**:
   Get your authentication token and authenticate Docker to your ECR registry.
   ```bash
   aws ecr get-login-password --region <your-region> | docker login --username AWS --password-stdin <aws_account_id>.dkr.ecr.<your-region>.amazonaws.com
   ```

3. **Tag your Docker image for ECR**:
   ```bash
   docker tag my-nodejs-web-app:latest <aws_account_id>.dkr.ecr.<your-region>.amazonaws.com/my-nodejs-web-app:latest
   ```

4. **Push the Docker image to ECR**:
   ```bash
   docker push <aws_account_id>.dkr.ecr.<your-region>.amazonaws.com/my-nodejs-web-app:latest
   ```

---

### Step 3: Set Up an ECS Cluster

1. **Create an ECS Cluster**:
   - Navigate to **ECS** in the AWS Console.
   - Choose "Create Cluster" and select either **Fargate** (serverless) or **EC2** (if you prefer managing EC2 instances).
   - If using EC2, select instance type, configure VPC, and select subnets/security groups.
   
   Using AWS CLI:
   ```bash
   aws ecs create-cluster --cluster-name my-ecs-cluster
   ```

---

### Step 4: Create an ECS Task Definition

1. **Create a Task Definition**:
   - Navigate to ECS > Task Definitions > Create new Task Definition.
   - Choose **Fargate** or **EC2** depending on your cluster.
   - Define your container settings (e.g., memory, CPU, and port mappings).

   Here’s an example configuration for the task definition:
   - **Container name**: my-nodejs-container
   - **Image**: `<aws_account_id>.dkr.ecr.<your-region>.amazonaws.com/my-nodejs-web-app:latest`
   - **Port mappings**: 8080:8080
   - **Memory**: 512 MiB
   - **CPU**: 256
   - **Environment Variables**: Set any required environment variables for your app here.
   
   Using AWS CLI:
   ```bash
   aws ecs register-task-definition \
       --family my-nodejs-task \
       --network-mode awsvpc \
       --container-definitions '[{
           "name": "my-nodejs-container",
           "image": "<aws_account_id>.dkr.ecr.<your-region>.amazonaws.com/my-nodejs-web-app:latest",
           "memory": 512,
           "cpu": 256,
           "essential": true,
           "portMappings": [{
               "containerPort": 8080,
               "hostPort": 8080,
               "protocol": "tcp"
           }]
       }]'
   ```

---

### Step 5: Deploy the Microservice on ECS

1. **Create an ECS Service**:
   - Go to ECS > Services > Create Service.
   - Choose the task definition you created, set the desired number of tasks, and configure an Application Load Balancer if required.
   - Set up the target group for the Load Balancer to route traffic to port 8080 of your container.

   Using AWS CLI:
   ```bash
   aws ecs create-service \
       --cluster my-ecs-cluster \
       --service-name my-nodejs-service \
       --task-definition my-nodejs-task \
       --desired-count 1 \
       --launch-type Fargate \
       --network-configuration '{
           "awsvpcConfiguration": {
               "subnets": ["<subnet-id>"],
               "securityGroups": ["<security-group-id>"],
               "assignPublicIp": "ENABLED"
           }
       }' \
       --load-balancers '[{
           "targetGroupArn": "<target-group-arn>",
           "containerName": "my-nodejs-container",
           "containerPort": 8080
       }]'
   ```

---

### Step 6: Monitor and Test the Setup

1. **Monitor ECS Services**:
   - Go to ECS and navigate to your cluster and service to check the status of your tasks.
   - Use **CloudWatch Logs** to monitor the logs of your application.

2. **Test the Application**:
   - If using a Load Balancer, get the DNS name from the **Load Balancer** section and test your Node.js app in the browser:
     ```bash
     curl http://<load-balancer-dns-name>
     ```
   
---

### Step 7: Cleanup

1. **Delete ECS Service**:
   ```bash
   aws ecs update-service --cluster my-ecs-cluster --service my-nodejs-service --desired-count 0
   aws ecs delete-service --cluster my-ecs-cluster --service my-nodejs-service
   ```

2. **Deregister Task Definition**:
   ```bash
   aws ecs deregister-task-definition --task-definition my-nodejs-task
   ```

3. **Delete ECS Cluster**:
   ```bash
   aws ecs delete-cluster --cluster my-ecs-cluster
   ```

4. **Delete ECR Repository**:
   ```bash
   aws ecr delete-repository --repository-name my-nodejs-web-app --force
   ```