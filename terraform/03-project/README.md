Let's walk through the **complete technical implementation** of deploying and optimizing your e-commerce platform with the provided **System Resource Monitoring Web App** using the architecture and recommendations I outlined earlier. Here, I’ll guide you step by step for the entire process, from setting up the infrastructure, deploying the app, automating with CI/CD, and monitoring everything.

### **Phase 1: Setup Highly Available Infrastructure**
This phase focuses on setting up the network and compute resources in a way that ensures high availability and cost-efficiency.

#### **Step 1: Create a VPC with Public and Private Subnets**
- **Action**: In AWS Console, create a new **VPC** with public and private subnets in at least **two availability zones (AZs)** for redundancy.
- **Steps**:
  1. Go to **VPC Console** and create a new VPC.
  2. Create two public subnets and two private subnets (one in each AZ).
  3. Create an **Internet Gateway** and attach it to your VPC for internet access to public subnets.
  4. Create **Route Tables**: 
      - One for public subnets (point traffic to the internet gateway).
      - One for private subnets (ensure instances in private subnets can communicate within the VPC).

#### **Step 2: Configure Security Groups and NACLs**
- **Action**: Configure **security groups** and **network access control lists (NACLs)** to control traffic.
  - Allow **SSH (port 22)** and **HTTP/HTTPS (ports 80/443)** for web servers.
  - Open ports for **Docker (2376)** and other services like **EC2 instances**.

---

### **Phase 2: EC2 Setup for Web Application Hosting**
We’ll use **EC2 Instances** to host the **System Resource Monitoring Web App**.

#### **Step 1: Create IAM Role for EC2 Access**
- **Action**: Attach an **IAM Role** to your EC2 instances to allow them to access other AWS resources securely (e.g., S3, CloudWatch).
- **Steps**:
  1. Go to **IAM Console** → Create a Role.
  2. Select **EC2** as the trusted entity and attach **AmazonS3ReadOnlyAccess**, **CloudWatchFullAccess**.
  3. Name the role, e.g., `EC2-Resource-Monitoring-Role`.

#### **Step 2: Launch EC2 Instances in Auto Scaling Group**
- **Action**: Launch EC2 instances using a mix of **Reserved Instances** for consistent load and **Spot Instances** for scaling. 
- **Steps**:
  1. Go to **EC2 Console** → Launch an EC2 instance.
  2. Choose **Amazon Linux 2** or **Ubuntu** AMI and select **t2.micro** for low cost (or adjust based on your needs).
  3. Attach the IAM role created earlier.
  4. Configure the instance in an **Auto Scaling Group** across both availability zones. 
  5. Add **Spot Instances** as part of the scaling strategy to save costs during peak times.

#### **Step 3: Install Docker on EC2 Instances**
- **Action**: Install **Docker** to containerize and run your application.
- **Steps**:
  1. SSH into your EC2 instance:
     ```bash
     ssh -i "your-key.pem" ec2-user@your-ec2-public-ip
     ```
  2. Install Docker on the EC2 instance:
     ```bash
     sudo yum update -y
     sudo yum install docker -y
     sudo service docker start
     sudo usermod -a -G docker ec2-user
     ```
  3. Test Docker installation:
     ```bash
     docker run hello-world
     ```

#### **Step 4: Clone and Set Up Your Application**
- **Action**: Clone the **System Resource Monitoring Web App** repository and run it with Docker.
- **Steps**:
  1. SSH into your EC2 instance.
  2. Install **git**:
     ```bash
     sudo yum install git -y
     ```
  3. Clone the repository:
     ```bash
     git clone https://github.com/swapnilyavalkar/system-resource-monitoring-web-app.git
     ```
  4. Navigate to the project directory and build the Docker image:
     ```bash
     cd system-resource-monitoring-web-app
     docker build -t resource-monitor-app .
     ```
  5. Run the application container:
     ```bash
     docker run -d -p 80:80 resource-monitor-app
     ```
  6. Verify the application is running by visiting the public IP of your EC2 instance in your browser.

---

### **Phase 3: Set Up RDS for Database**
We’ll use **Amazon RDS** to host the database for persistent storage.

#### **Step 1: Set Up RDS with Multi-AZ**
- **Action**: Create an RDS database (e.g., **PostgreSQL**) with Multi-AZ deployment for high availability.
- **Steps**:
  1. Go to **RDS Console** and click **Create Database**.
  2. Select **PostgreSQL**, enable **Multi-AZ** deployment.
  3. Select a **DB Instance Class** such as `db.t3.micro` for a small environment.
  4. Enable automated backups, set retention to 7 days.
  5. Create a new **security group** that allows inbound connections from your EC2 instances.

#### **Step 2: Connect the Application to RDS**
- **Action**: Update the application’s database connection settings to point to your new RDS instance.
- **Steps**:
  1. Find the **Endpoint** of the RDS instance from the console.
  2. Modify the app's environment variables or configuration files to use the RDS endpoint, username, and password.

---

### **Phase 4: Implement CI/CD Pipeline**
Set up **Jenkins** or **AWS CodePipeline** to automate the deployment process.

#### **Step 1: Set Up Jenkins on EC2**
- **Action**: Install and configure Jenkins to automate code building and deployment.
- **Steps**:
  1. Launch a new EC2 instance to host **Jenkins**.
  2. SSH into the instance and install Jenkins:
     ```bash
     sudo yum update -y
     sudo wget -O /etc/yum.repos.d/jenkins.repo \
     https://pkg.jenkins.io/redhat-stable/jenkins.repo
     sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
     sudo yum install jenkins java-1.8.0-openjdk-devel -y
     sudo systemctl start jenkins
     ```
  3. Access Jenkins through your browser using `http://<instance-public-ip>:8080`.

#### **Step 2: Configure Jenkins Pipeline**
- **Action**: Set up a pipeline to build and deploy the Docker image automatically.
- **Steps**:
  1. Create a new pipeline in Jenkins, connect it to your GitHub repository.
  2. Define your pipeline stages in a `Jenkinsfile`:
     ```groovy
     pipeline {
        agent any
        stages {
            stage('Build') {
                steps {
                    script {
                        sh 'docker build -t resource-monitor-app .'
                    }
                }
            }
            stage('Deploy') {
                steps {
                    script {
                        sh 'docker run -d -p 80:80 resource-monitor-app'
                    }
                }
            }
        }
     }
     ```
  3. Configure the pipeline to trigger on every commit to the GitHub repository.

---

### **Phase 5: Monitoring and Logging**
Now, we need to monitor both the infrastructure and the application to ensure everything runs smoothly.

#### **Step 1: Set Up CloudWatch Monitoring**
- **Action**: Use **Amazon CloudWatch** to monitor EC2, RDS, and ECS metrics.
- **Steps**:
  1. Go to **CloudWatch Console** and create dashboards for your EC2 instances, RDS database, and Auto Scaling groups.
  2. Enable **CloudWatch Alarms** to notify you when CPU usage, memory, or disk space crosses thresholds.

#### **Step 2: Use AWS X-Ray for Tracing**
- **Action**: Use **AWS X-Ray** to trace application requests and monitor performance bottlenecks.
- **Steps**:
  1. Install X-Ray on your EC2 instances:
     ```bash
     sudo yum install -y awslogs aws-cli
     sudo yum install -y aws-xray-daemon
     sudo systemctl start aws-xray
     ```
  2. Enable X-Ray SDK in your application to capture traces and analyze performance.

#### **Step 3: Set Up Centralized Logging**
- **Action**: Configure **CloudWatch Logs** to aggregate logs from EC2 instances, Docker containers, and RDS.
- **Steps**:
  1. Install the **CloudWatch Logs agent** on EC2:
     ```bash
     sudo yum install -y awslogs
     ```
  2. Configure the agent to forward application logs to **CloudWatch Logs**.

---

### **Phase 6: Cost Optimization**

#### **Step 1: Right-sizing EC2 and RDS Instances**
- **Steps**:
  1. Go to the **AWS Trusted Advisor** or **AWS Compute Optimizer** dashboard.
  2. Review the recommendations for underutilized or overprovisioned instances and databases.
  3. Adjust EC2 instance types or RDS configurations based on actual usage patterns. For example, if a `t2.large` is being underutilized, switch to a `t3.medium` for lower costs.

#### **Step 2: Use Spot Instances for Dynamic Workloads**
- **Action**: Leverage **EC2 Spot Instances** for non-critical, fault-tolerant tasks like worker nodes or batch jobs.
- **Steps**:
  1. In the **Auto Scaling Group** configuration, enable **Spot Instances** for workloads that can tolerate interruptions.
  2. Set appropriate instance weights and scaling policies for using Spot Instances during periods of high demand, while reserving On-Demand or Reserved Instances for critical components.

#### **Step 3: S3 Storage Optimization**
- **Action**: Implement **S3 Lifecycle Policies** to move older logs, backups, and infrequently accessed data to **S3 Glacier** or **S3 Intelligent-Tiering** for cost savings.
- **Steps**:
  1. Go to the **S3 Console** and select the bucket used for storing logs and backups.
  2. Create a **Lifecycle Policy** to automatically transition objects to **S3 Glacier** after a certain period (e.g., after 30 days for logs).
  3. Enable **S3 Intelligent-Tiering** on buckets where access patterns are unpredictable.

---

### **Final Step: Testing and Validation**

#### **Step 1: Test the Application**
- **Action**: Perform comprehensive testing of the **System Resource Monitoring Web App** to ensure it works correctly on the infrastructure.
- **Steps**:
  1. Open the **public IP address** or the **Load Balancer DNS** in a browser to access the application.
  2. Test various features such as resource monitoring, real-time updates, and performance metrics.
  3. Check logs in **CloudWatch Logs** to confirm that logs are being captured correctly.

#### **Step 2: Validate High Availability**
- **Action**: Test failover and load balancing functionality.
- **Steps**:
  1. Simulate an EC2 instance failure by stopping one of the instances. Verify that the **Auto Scaling Group** launches a replacement instance in another availability zone.
  2. Perform a **load test** using a tool like **Apache JMeter** or **Artillery** to ensure the application can handle high traffic, and monitor how the infrastructure scales with demand.

#### **Step 3: Validate CI/CD Pipeline**
- **Action**: Validate the Jenkins pipeline to ensure that changes are deployed automatically.
- **Steps**:
  1. Make a small change to the application codebase (e.g., update the homepage text).
  2. Commit and push the change to your **GitHub** repository.
  3. Watch the **Jenkins pipeline** run, build the Docker image, and deploy the updated version to your EC2 instances.
  4. Validate the change in the web application after deployment.

#### **Step 4: Validate Monitoring and Alerts**
- **Action**: Ensure CloudWatch monitoring and X-Ray tracing are working correctly.
- **Steps**:
  1. Trigger high CPU or memory usage by stressing the application.
  2. Check **CloudWatch Dashboards** to verify that the metrics are being tracked properly.
  3. Confirm that **CloudWatch Alarms** trigger email or SMS notifications when resource thresholds are breached.
  4. Check **AWS X-Ray** traces to see if any latency or bottlenecks are present in the application request flows.

---

### **Summary of Key Components and Why We Used Them**

- **VPC with Public and Private Subnets**: Ensures secure, isolated networking across multiple AZs for high availability.
- **EC2 with Auto Scaling**: Ensures that the compute layer can scale up or down based on demand, using Spot and Reserved Instances for cost-efficiency.
- **Elastic Load Balancer (ELB)**: Provides fault tolerance by distributing incoming traffic across healthy instances in multiple AZs.
- **Docker**: Used to containerize the web app, ensuring portability and consistency across environments.
- **Amazon RDS (Multi-AZ)**: Provides highly available, managed relational database services with automated backups and failover.
- **Jenkins Pipeline**: Automates the CI/CD process, allowing for automatic builds, testing, and deployment to EC2 instances using Docker.
- **CloudWatch Monitoring & X-Ray**: Ensures you can monitor the health and performance of the infrastructure and application in real time, and trace issues with X-Ray.
- **S3 Storage**: Used for storing backups, logs, and static content, with cost optimizations via lifecycle policies.

---

### **Next Steps: Scaling and Enhancements**

Once you’ve validated that everything is working as expected, you can focus on further optimizing and scaling:

1. **Set Up Multi-Region Deployment**: If global availability is required, deploy the infrastructure in multiple regions and use **Route 53** for DNS-based load balancing and failover.
2. **Integrate Application Load Balancer with WAF (Web Application Firewall)**: Add **AWS WAF** to protect against common web vulnerabilities like SQL injection and DDoS attacks.
3. **Further Cost Optimization**: Regularly review usage patterns and leverage tools like **AWS Cost Explorer** to find areas to optimize costs further.
4. **Add Caching**: Implement **Amazon ElastiCache** (Redis or Memcached) to reduce database load and improve performance during high traffic periods.

By following these comprehensive steps, your **System Resource Monitoring Web App** will be deployed on a robust, highly available, and cost-optimized AWS infrastructure. All recommendations provided earlier have been applied to ensure the platform is scalable, fault-tolerant, and automated.


---

# Using Terraform:

Let’s go through the **detailed breakdown** of each component and apply **best practices** in Terraform to organize the project effectively. This will help you understand the importance of each keyword and file in Terraform while also implementing a clean and modular approach for your e-commerce platform with the **System Resource Monitoring Web App**.

---

## **Terraform Structure and Best Practices**

A well-structured Terraform project is critical for maintainability, reusability, and scalability. We'll organize the project into modules and split the configuration into different files for better readability and management. Here's how the structure looks:

### **1. File Structure**
We’ll use the following Terraform file structure for this project:

```
/resource-monitoring-app/
  ├── main.tf
  ├── variables.tf
  ├── outputs.tf
  ├── provider.tf
  ├── terraform.tfvars
  ├── /modules/
  │    ├── vpc/
  │    │    ├── main.tf
  │    │    ├── variables.tf
  │    │    ├── outputs.tf
  │    ├── ec2/
  │    │    ├── main.tf
  │    │    ├── variables.tf
  │    │    ├── outputs.tf
  │    ├── rds/
  │    │    ├── main.tf
  │    │    ├── variables.tf
  │    │    ├── outputs.tf
```

### **2. Explanation of Each File**

1. **main.tf**:
   This is the root configuration file where you reference and call modules. You won’t define resources directly here but rather use modules to provision resources.
   
2. **provider.tf**:
   Defines the AWS provider configuration.

3. **variables.tf**:
   Defines input variables for the project. Variables are used to parameterize the configuration, making it reusable and adaptable for different environments (e.g., dev, staging, production).

4. **terraform.tfvars**:
   This file holds the values for the variables defined in `variables.tf`.

5. **outputs.tf**:
   This file captures and outputs important values, such as instance IP addresses or database connection endpoints.

6. **/modules/**:
   This folder contains sub-modules, which are reusable components like **VPC**, **EC2**, and **RDS**.

### **3. Key Concepts and Keywords**

Before diving into code, let’s explain key Terraform concepts and keywords:

- **`provider`**: Defines the AWS provider (or other cloud providers) to allow Terraform to interact with the AWS resources.
- **`resource`**: The main building block in Terraform, representing a single AWS resource (e.g., EC2 instance, VPC, S3 bucket). Each `resource` block provisions an instance of the specified resource type.
- **`module`**: Reusable components that encapsulate related resources, variables, and outputs. Modules make the configuration modular and DRY (Don’t Repeat Yourself).
- **`variable`**: Input values that make the Terraform configuration flexible and customizable.
- **`output`**: Provides visibility to the results of the infrastructure creation (e.g., IP addresses, DNS names).
- **`data`**: Fetches data from existing infrastructure or services (e.g., fetching an existing AMI ID).
- **`locals`**: Variables internal to the module that hold commonly used values.

---

## **Terraform Code with Detailed Explanations**

### **1. Root-Level Files**

#### **provider.tf**
The provider file configures the AWS provider.

```hcl
provider "aws" {
  region = var.aws_region   # Referencing the variable from variables.tf
}
```

- **Explanation**:
  - **`provider`**: The provider block tells Terraform which provider (AWS, GCP, etc.) to use. In this case, it’s AWS.
  - **`region`**: Specifies the AWS region (e.g., `us-west-2`). The value is pulled from a variable called `aws_region`.

#### **variables.tf**
Variables defined here are referenced in your Terraform code.

```hcl
variable "aws_region" {
  description = "The AWS region to deploy the infrastructure in."
  type        = string
  default     = "us-west-2"
}

variable "instance_type" {
  description = "The type of EC2 instance to deploy."
  type        = string
  default     = "t2.micro"
}

variable "app_name" {
  description = "The name of the application."
  type        = string
  default     = "resource-monitoring-app"
}
```

- **Explanation**:
  - **`variable`**: Each block defines an input variable. These allow you to customize your configuration without changing the actual Terraform code.
  - **`type`**: Specifies the data type for the variable (e.g., string, list, map).
  - **`default`**: A default value that will be used if the variable is not explicitly provided in `terraform.tfvars`.

#### **terraform.tfvars**
This file holds the actual values of variables to be used during execution.

```hcl
aws_region    = "us-west-2"
instance_type = "t2.micro"
app_name      = "resource-monitoring-app"
```

- **Explanation**: This file overrides default values in `variables.tf`. It allows you to change variables based on the environment or specific use cases.

#### **outputs.tf**
This file captures important values to display after applying the configuration.

```hcl
output "vpc_id" {
  description = "The ID of the VPC created"
  value       = module.vpc.vpc_id
}

output "ec2_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = module.ec2.instance_public_ip
}
```

- **Explanation**:
  - **`output`**: Outputs provide visibility into key infrastructure values, such as VPC IDs or EC2 instance IPs. They are useful for debugging and integrating with other systems.

---

### **2. Module: VPC (modules/vpc/)**

This module creates a highly available VPC with public and private subnets.

#### **main.tf**
```hcl
resource "aws_vpc" "main_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = var.app_name
  }
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private_subnet_a" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-west-2a"
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
}
```

- **Explanation**:
  - **`resource`**: Each resource block creates an AWS resource. For example, `aws_vpc` creates a VPC, and `aws_subnet` creates subnets within that VPC.
  - **`cidr_block`**: Defines the CIDR block (IP range) for the VPC.
  - **`map_public_ip_on_launch`**: Ensures that instances in the public subnet get public IPs.

#### **variables.tf**
Defines input variables for the VPC module.

```hcl
variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "app_name" {
  description = "The name of the application."
  type        = string
}
```

#### **outputs.tf**
Outputs the VPC ID.

```hcl
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main_vpc.id
}
```

---

### **3. Module: EC2 (modules/ec2/)**

This module provisions an EC2 instance with user data that installs Docker and runs your app.

#### **main.tf**
```hcl
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  security_groups = [var.security_group]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install docker -y
              sudo service docker start
              sudo usermod -aG docker ec2-user
              docker run -d -p 80:80 swapnilyavalkar/system-resource-monitoring-web-app
              EOF
}
```

- **Explanation**:
  - **`user_data`**: A script executed when the instance launches, used to install Docker, start the Docker service, and run the application.
  - **`instance_type`**: Refers to the type of instance (e.g., `t2.micro`).
  - **`ami_id`**: The Amazon Machine Image (AMI) used to launch the

Sure! Let’s continue with the rest of the Terraform configuration. In the previous section, we started with the EC2 module. We'll now complete the EC2 module, add the RDS module, and then finish the project with CI/CD, logging, and monitoring configuration.

---

### **3. Module: EC2 (modules/ec2/)** (continued)

#### **variables.tf**
Defines input variables for the EC2 module.

```hcl
variable "ami_id" {
  description = "AMI ID to use for the EC2 instance."
  type        = string
  default     = "ami-0c55b159cbfafe1f0"  # Replace with a valid AMI ID
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t2.micro"
}

variable "subnet_id" {
  description = "The subnet ID in which to launch the instance."
  type        = string
}

variable "security_group" {
  description = "Security group for the instance."
  type        = string
}
```

- **Explanation**:
  - **`ami_id`**: Specifies the Amazon Machine Image (AMI) used to launch the EC2 instance.
  - **`instance_type`**: Determines the size of the instance (e.g., `t2.micro`).
  - **`subnet_id`**: The subnet where the instance will be launched, which comes from the VPC module.
  - **`security_group`**: The security group to be applied to the EC2 instance for controlling network access.

#### **outputs.tf**
Outputs key information about the EC2 instance, such as its public IP.

```hcl
output "instance_public_ip" {
  description = "The public IP address of the EC2 instance."
  value       = aws_instance.web.public_ip
}

output "instance_id" {
  description = "The ID of the EC2 instance."
  value       = aws_instance.web.id
}
```

- **Explanation**:
  - **`instance_public_ip`**: Exports the public IP address of the EC2 instance, useful for accessing the instance over the internet.
  - **`instance_id`**: Outputs the ID of the EC2 instance.

---

### **4. Module: RDS (modules/rds/)**

This module provisions an RDS database for the application.

#### **main.tf**
```hcl
resource "aws_db_instance" "app_db" {
  allocated_storage    = var.db_allocated_storage
  engine               = var.db_engine
  instance_class       = var.db_instance_class
  name                 = var.db_name
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = var.parameter_group_name
  multi_az             = var.multi_az
  vpc_security_group_ids = [var.security_group]
  storage_encrypted    = true
  skip_final_snapshot  = true

  tags = {
    Name = var.app_name
  }
}
```

- **Explanation**:
  - **`aws_db_instance`**: Provisions an RDS instance for the application.
  - **`multi_az`**: Enables **Multi-AZ** deployment for high availability, which automatically fails over to another availability zone in case of an outage.
  - **`vpc_security_group_ids`**: Associates the RDS instance with the appropriate security group, restricting access to trusted resources only.

#### **variables.tf**
Defines input variables for the RDS module.

```hcl
variable "db_allocated_storage" {
  description = "The amount of storage (in gigabytes) to allocate to the database."
  type        = number
  default     = 20
}

variable "db_engine" {
  description = "The database engine to use (e.g., postgres, mysql)."
  type        = string
  default     = "postgres"
}

variable "db_instance_class" {
  description = "The instance class for the RDS instance."
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "The name of the database."
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "The username for the database."
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "The password for the database."
  type        = string
}

variable "parameter_group_name" {
  description = "The DB parameter group to associate with the instance."
  type        = string
  default     = "default.postgres12"
}

variable "multi_az" {
  description = "Whether to deploy the RDS instance in a Multi-AZ configuration."
  type        = bool
  default     = true
}

variable "security_group" {
  description = "Security group for the RDS instance."
  type        = string
}

variable "app_name" {
  description = "The name of the application."
  type        = string
}
```

- **Explanation**:
  - **`db_allocated_storage`**: Specifies the storage capacity for the RDS instance.
  - **`db_engine`**: Specifies which database engine to use (e.g., PostgreSQL, MySQL).
  - **`db_instance_class`**: Defines the size of the RDS instance.
  - **`db_username`** and **`db_password`**: Used to configure the credentials for the database.

#### **outputs.tf**
Outputs key information about the RDS instance.

```hcl
output "rds_endpoint" {
  description = "The connection endpoint for the RDS instance."
  value       = aws_db_instance.app_db.endpoint
}

output "rds_db_name" {
  description = "The name of the RDS database."
  value       = aws_db_instance.app_db.name
}
```

- **Explanation**:
  - **`rds_endpoint`**: Outputs the endpoint URL used to connect to the RDS instance.
  - **`rds_db_name`**: Outputs the name of the database provisioned within the RDS instance.

---

### **5. Logging and Monitoring**

We’ll now configure **CloudWatch** for logging and monitoring, as well as **SNS** for alerts.

#### **main.tf (root level)**

Add the following resources to handle logging and monitoring in `main.tf`.

```hcl
module "cloudwatch" {
  source = "./modules/cloudwatch"
}

module "sns" {
  source = "./modules/sns"
}
```

### **Module: CloudWatch (modules/cloudwatch/)**

#### **main.tf**
```hcl
resource "aws_cloudwatch_log_group" "app_log_group" {
  name = "/ecs/resource-monitoring-app"
  retention_in_days = 30
}

resource "aws_cloudwatch_metric_alarm" "cpu_high_alarm" {
  alarm_name          = "cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Triggered when CPU exceeds 80% for 2 periods"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    InstanceId = var.instance_id
  }
}
```

- **Explanation**:
  - **`aws_cloudwatch_log_group`**: Creates a log group in CloudWatch for your application logs.
  - **`aws_cloudwatch_metric_alarm`**: Creates a CloudWatch alarm that triggers when the CPU utilization of the EC2 instance exceeds 80%.

#### **variables.tf**
```hcl
variable "instance_id" {
  description = "The ID of the EC2 instance to monitor."
  type        = string
}
```

### **Module: SNS (modules/sns/)**

#### **main.tf**
```hcl
resource "aws_sns_topic" "alerts" {
  name = "app-alerts"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}
```

- **Explanation**:
  - **`aws_sns_topic`**: Creates an SNS topic for sending alerts.
  - **`aws_sns_topic_subscription`**: Configures an email subscription to receive the SNS alerts.

#### **variables.tf**
```hcl
variable "alert_email" {
  description = "Email address for receiving alerts."
  type        = string
}
```

---

Let’s complete the **root-level `main.tf`** and tie everything together.

### **6. Root-Level `main.tf`** (continued)

Here is the continuation and completion of the `main.tf` file in the root directory, where we tie all the modules together for provisioning the entire infrastructure:

```hcl
provider "aws" {
  region = var.aws_region
}

# VPC module to create networking resources
module "vpc" {
  source = "./modules/vpc"

  app_name = var.app_name
  vpc_cidr = var.vpc_cidr
}

# EC2 module to provision the application instance
module "ec2" {
  source = "./modules/ec2"

  ami_id          = var.ami_id
  instance_type   = var.instance_type
  subnet_id       = module.vpc.public_subnet_id
  security_group  = module.vpc.security_group_id
}

# RDS module for the database
module "rds" {
  source = "./modules/rds"

  db_name         = var.db_name
  db_username     = var.db_username
  db_password     = var.db_password
  security_group  = module.vpc.security_group_id
}

# CloudWatch module for logging and monitoring
module "cloudwatch" {
  source = "./modules/cloudwatch"

  instance_id = module.ec2.instance_id
}

# SNS module for sending alerts
module "sns" {
  source = "./modules/sns"

  alert_email = var.alert_email
}
```

### **Root-Level Files**

Here are the supporting files in the root directory to complete the setup:

#### **variables.tf**

This file holds the root-level variables that are passed into modules.

```hcl
variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-west-2"
}

variable "app_name" {
  description = "The name of the application."
  type        = string
  default     = "resource-monitoring-app"
}

variable "ami_id" {
  description = "The AMI ID for the EC2 instance."
  type        = string
}

variable "instance_type" {
  description = "The EC2 instance type."
  type        = string
  default     = "t2.micro"
}

variable "db_name" {
  description = "The name of the RDS database."
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "The RDS database username."
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "The RDS database password."
  type        = string
  sensitive   = true
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "alert_email" {
  description = "Email address for SNS alerts."
  type        = string
}
```

#### **terraform.tfvars**

This file holds the actual values that override default variables, which you can adjust for different environments (e.g., dev, staging, production).

```hcl
aws_region    = "us-west-2"
ami_id        = "ami-0c55b159cbfafe1f0"  # Replace with valid AMI
db_password   = "your_db_password"
alert_email   = "your-email@example.com"
```

#### **outputs.tf**

This file defines the outputs from the root-level modules to display important information after Terraform applies the configuration.

```hcl
output "vpc_id" {
  description = "The ID of the VPC."
  value       = module.vpc.vpc_id
}

output "ec2_public_ip" {
  description = "The public IP address of the EC2 instance."
  value       = module.ec2.instance_public_ip
}

output "rds_endpoint" {
  description = "The endpoint of the RDS instance."
  value       = module.rds.rds_endpoint
}

output "cloudwatch_log_group" {
  description = "The CloudWatch log group for application logs."
  value       = module.cloudwatch.app_log_group
}
```

---

### **Final Review: How the Project is Organized**

- **Root Module**: The root module references each sub-module, passing in the necessary variables and connecting them.
- **VPC Module**: Handles all networking-related resources, such as the VPC, subnets, and security groups.
- **EC2 Module**: Provisions the EC2 instance with Docker, configured to run the System Resource Monitoring Web App.
- **RDS Module**: Manages the creation of the database using Amazon RDS with multi-AZ for high availability.
- **CloudWatch Module**: Configures logging, monitoring, and alarms for the application and EC2 instances.
- **SNS Module**: Configures alerts to notify the user in case of issues, such as high CPU usage.

---

### **Step-by-Step Instructions to Deploy the Project Using Terraform**

1. **Clone or create the directory structure** as described above and add the necessary files (`main.tf`, `variables.tf`, `outputs.tf`, `terraform.tfvars`, and the module directories).

2. **Install Terraform** and AWS CLI if not already installed:
   - [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli).
   - [Install AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html).

3. **Configure AWS CLI** by running:
   ```bash
   aws configure
   ```
   Set your AWS **Access Key**, **Secret Key**, **Region**, and **Output format**.

4. **Initialize Terraform** in the root directory by running:
   ```bash
   terraform init
   ```
   This downloads and sets up the required provider plugins (in this case, AWS).

5. **Validate the configuration** to ensure everything is correct:
   ```bash
   terraform validate
   ```

6. **Plan the infrastructure** to see what Terraform will create:
   ```bash
   terraform plan
   ```

7. **Apply the configuration** to create the infrastructure:
   ```bash
   terraform apply
   ```
   This will show the execution plan and ask for confirmation. Type `yes` to proceed.

8. **Check the outputs** after Terraform completes. You’ll see outputs like the VPC ID, EC2 public IP, RDS endpoint, and more.

9. **Access the application** by visiting the public IP of the EC2 instance in your browser:
   ```
   http://<EC2 Public IP>
   ```

10. **Monitor the infrastructure** using CloudWatch metrics and logs, and receive **SNS alerts** when any issues occur (such as high CPU usage).

---

### **Final Explanation of Key Concepts and Best Practices**

- **Provider**: We specify the **AWS provider** to allow Terraform to manage AWS resources.
- **Modules**: We use modules to structure the Terraform configuration into logical and reusable components (e.g., VPC, EC2, RDS).
- **Variables**: Input variables make the configuration flexible and adaptable for different environments (e.g., dev, prod).
- **Outputs**: Outputs provide key information (e.g., public IPs, database endpoints) after the infrastructure is provisioned.
- **Security**: Sensitive data like the RDS database password is handled securely using **sensitive** variables.
- **Monitoring**: CloudWatch is used to log and monitor the EC2 instance and application, while SNS sends alerts when thresholds (e.g., CPU usage) are exceeded.

---

### **Next Steps and Enhancements**

- **Multi-Region Deployment**: You could expand this infrastructure to deploy across multiple AWS regions for global high availability.
- **Additional Services**: Integrate other services like **Route 53** for DNS management or **ElastiCache** for caching to further optimize the application’s performance.
- **CI/CD Integration**: Set up **AWS CodePipeline** or Jenkins for continuous deployment to automatically apply changes to infrastructure and application code.

With this setup, your project is structured following Terraform best practices, making it easier to maintain, scale, and adapt to future requirements.

---

Certainly! To use **Jenkins** and **Docker** for CI/CD in your Terraform infrastructure, we’ll configure Jenkins on an EC2 instance and set up the required IAM roles, security groups, and S3 bucket for storing build artifacts. Jenkins will automate the process of building Docker images and deploying the application.

Here’s a step-by-step guide to implement Jenkins with Docker in your Terraform project.

---

### **5. CI/CD with Jenkins and Docker**

#### **Step 1: Jenkins Installation on EC2 Using Terraform**

We’ll provision an EC2 instance for Jenkins with the necessary user data to install Jenkins and Docker. This EC2 instance will be used as the Jenkins server.

#### **1.1 Jenkins EC2 Instance**

In the **`main.tf`** for your EC2 module, add a separate EC2 instance for Jenkins.

```hcl
resource "aws_instance" "jenkins_server" {
  ami           = var.jenkins_ami_id   # Jenkins-ready AMI or Linux AMI
  instance_type = var.jenkins_instance_type
  subnet_id     = module.vpc_primary.public_subnet_id
  security_groups = [module.vpc_primary.jenkins_sg]

  key_name      = var.key_pair

  # Jenkins installation and Docker setup
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y java-1.8.0-openjdk
              sudo wget -O /etc/yum.repos.d/jenkins.repo \
                  https://pkg.jenkins.io/redhat-stable/jenkins.repo
              sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
              sudo yum install -y jenkins
              sudo systemctl start jenkins
              sudo systemctl enable jenkins

              # Install Docker
              sudo yum install docker -y
              sudo service docker start
              sudo usermod -aG docker jenkins
              sudo systemctl restart jenkins
              EOF

  tags = {
    Name = "JenkinsServer"
  }
}
```

- **Explanation**:
  - **AMI**: We are using an **Amazon Linux 2** AMI (or a Jenkins-ready AMI).
  - **`user_data`**: The script installs Jenkins and Docker. Jenkins is configured to run as a service and have Docker access for building images.

#### **1.2 Security Group for Jenkins**

You’ll also need a security group for the Jenkins instance, which allows HTTP access (port 8080) and SSH access (port 22).

```hcl
resource "aws_security_group" "jenkins_sg" {
  vpc_id = module.vpc_primary.vpc_id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open to the world (use specific IP ranges for security)
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "JenkinsSecurityGroup"
  }
}
```

- **Explanation**:
  - This security group allows traffic on port **8080** for the Jenkins web interface and port **22** for SSH access.

#### **1.3 Variables for Jenkins**

In **`variables.tf`**, add the variables for the Jenkins instance.

```hcl
variable "jenkins_ami_id" {
  description = "AMI ID for Jenkins EC2 instance."
  type        = string
  default     = "ami-0c55b159cbfafe1f0"  # Replace with a valid Jenkins/Linux AMI
}

variable "jenkins_instance_type" {
  description = "Instance type for Jenkins server."
  type        = string
  default     = "t2.medium"
}

variable "key_pair" {
  description = "Key pair for SSH access to Jenkins instance."
  type        = string
}
```

#### **1.4 Outputs for Jenkins**

In **`outputs.tf`**, output the Jenkins instance’s public IP address.

```hcl
output "jenkins_public_ip" {
  description = "Public IP address of the Jenkins server."
  value       = aws_instance.jenkins_server.public_ip
}
```

---

### **Step 2: Configure Jenkins Jobs for CI/CD**

Once Jenkins is up and running on the EC2 instance, you’ll need to:

1. **Access Jenkins**: 
   - Visit `http://<Jenkins_Public_IP>:8080`.
   - Unlock Jenkins using the admin password located in `/var/lib/jenkins/secrets/initialAdminPassword` on the EC2 instance.
   
2. **Install Required Jenkins Plugins**:
   - **Git**: For pulling the application’s source code from a GitHub repository.
   - **Docker**: For building and pushing Docker images.
   - **Pipeline**: For creating Jenkins pipelines as code.

3. **Create a Jenkins Pipeline Job**:
   In the Jenkins web interface, create a new pipeline job that automates the following:

   - **Pull the source code** from your GitHub repository.
   - **Build the Docker image** for the application.
   - **Push the Docker image** to DockerHub or Amazon Elastic Container Registry (ECR).
   - **Deploy the Docker container** on the target EC2 instances.

4. **Jenkinsfile Example**:
   Create a **Jenkinsfile** in your GitHub repository that Jenkins will use to build and deploy the application.

   ```groovy
   pipeline {
       agent any

       environment {
           DOCKERHUB_CREDENTIALS = credentials('dockerhub')  // DockerHub credentials stored in Jenkins
       }

       stages {
           stage('Clone repository') {
               steps {
                   git 'https://github.com/swapnilyavalkar/system-resource-monitoring-web-app.git'
               }
           }

           stage('Build Docker image') {
               steps {
                   script {
                       docker.build("your-dockerhub-username/resource-monitoring-app:latest")
                   }
               }
           }

           stage('Push Docker image') {
               steps {
                   script {
                       docker.withRegistry('https://index.docker.io/v1/', 'DOCKERHUB_CREDENTIALS') {
                           docker.image("your-dockerhub-username/resource-monitoring-app:latest").push()
                       }
                   }
               }
           }

           stage('Deploy to EC2') {
               steps {
                   sshagent(['ec2-key-pair']) {
                       sh 'ssh -o StrictHostKeyChecking=no ec2-user@<EC2_PUBLIC_IP> docker pull your-dockerhub-username/resource-monitoring-app:latest'
                       sh 'ssh ec2-user@<EC2_PUBLIC_IP> docker run -d -p 80:80 your-dockerhub-username/resource-monitoring-app:latest'
                   }
               }
           }
       }

       post {
           always {
               cleanWs()
           }
       }
   }
   ```

   - **Explanation**:
     - **Clone repository**: Pulls the application code from the GitHub repository.
     - **Build Docker image**: Builds a Docker image using the codebase.
     - **Push Docker image**: Pushes the image to **DockerHub** or **Amazon ECR**.
     - **Deploy to EC2**: SSHs into the target EC2 instance and pulls/runs the new Docker image.

   **Note**: Replace `<EC2_PUBLIC_IP>` with the public IP address of the EC2 instance that will run the Docker container. The `sshagent` block uses the SSH key configured in Jenkins to access the EC2 instance.

---

### **Step 3: Terraform IAM Role for Jenkins**

To allow Jenkins to interact with AWS services (e.g., EC2, S3, ECR), we need an IAM role with sufficient permissions.

#### **IAM Role for Jenkins**

Add this IAM role for Jenkins in **`main.tf`**.

```hcl
resource "aws_iam_role" "jenkins_role" {
  name = "jenkins-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "jenkins_policy" {
  name        = "jenkins-policy"
  description = "Policy for Jenkins EC2 instance to access S3, ECR, and EC2."
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:*",
          "s3:*",
          "ec2:*"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "jenkins_policy_attach" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = aws_iam_policy.jenkins_policy.arn
}
```

- **Explanation**:
  - **IAM Role**: Allows the Jenkins EC2 instance to assume a role that has access to **ECR**, **S3**, and **EC2**.
  - **IAM Policy**: Grants permissions to **list, push, and pull Docker images

Let’s continue where we left off and complete the project. We were configuring Jenkins with Docker and providing it with the necessary IAM role and permissions. Below is the final completion of the Terraform configuration, including the IAM policy, key pair, final Jenkins pipeline setup, and connection to EC2 for deployments.

### **Step 3: Complete the IAM Role and Policy for Jenkins**

We already defined the IAM role and policy for Jenkins in the previous step. Let’s now complete the remaining components, including the key pair, to allow Jenkins to SSH into EC2 instances for deployment.

#### **IAM Role and Policy (continued)**

The IAM role will be attached to the EC2 instance running Jenkins, allowing it to interact with **EC2**, **S3**, and **ECR**.

```hcl
resource "aws_iam_instance_profile" "jenkins_instance_profile" {
  name = "jenkins-instance-profile"
  role = aws_iam_role.jenkins_role.name
}
```

- **Explanation**: The **IAM instance profile** is used to attach the IAM role to the Jenkins EC2 instance so it can assume the role and access the required AWS services.

---

### **Step 4: Key Pair for Jenkins to SSH into EC2**

For Jenkins to SSH into the EC2 instances where the application is deployed, it needs a key pair.

#### **Create Key Pair in AWS Console or Import Existing Key**

You can either generate a key pair in the AWS Console or import an existing key pair. If you are using Terraform to manage the key pair, add the following resource:

```hcl
resource "aws_key_pair" "ec2_key_pair" {
  key_name   = var.key_pair_name
  public_key = file(var.public_key_path)
}
```

- **Explanation**:
  - **`key_name`**: The name of the key pair.
  - **`public_key`**: The path to the public key that will be used for SSH access.

#### **Variables for Key Pair**

Add the variables in `variables.tf` for the key pair configuration:

```hcl
variable "key_pair_name" {
  description = "The name of the key pair to use for SSH access."
  type        = string
}

variable "public_key_path" {
  description = "The path to the public key file."
  type        = string
}
```

- **Explanation**:
  - These variables allow you to pass in the public key path and key pair name dynamically.

---

### **Step 5: Jenkins Final Setup and Connection to EC2**

With the IAM role, key pair, and Jenkins instance in place, we’ll configure Jenkins to deploy the Dockerized application on EC2.

#### **Jenkinsfile for Deployment**

In your **Jenkinsfile** (stored in your GitHub repository), you’ll define the pipeline to automate the deployment process.

```groovy
pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub')  // DockerHub credentials stored in Jenkins
    }

    stages {
        stage('Clone repository') {
            steps {
                git 'https://github.com/swapnilyavalkar/system-resource-monitoring-web-app.git'
            }
        }

        stage('Build Docker image') {
            steps {
                script {
                    docker.build("your-dockerhub-username/resource-monitoring-app:latest")
                }
            }
        }

        stage('Push Docker image') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'DOCKERHUB_CREDENTIALS') {
                        docker.image("your-dockerhub-username/resource-monitoring-app:latest").push()
                    }
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                sshagent(['ec2-key-pair']) {
                    sh 'ssh -o StrictHostKeyChecking=no ec2-user@<EC2_PUBLIC_IP> docker pull your-dockerhub-username/resource-monitoring-app:latest'
                    sh 'ssh ec2-user@<EC2_PUBLIC_IP> docker stop $(docker ps -q)'
                    sh 'ssh ec2-user@<EC2_PUBLIC_IP> docker run -d -p 80:80 your-dockerhub-username/resource-monitoring-app:latest'
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
```

- **Explanation**:
  - **Clone repository**: Pulls the latest code from GitHub.
  - **Build Docker image**: Builds a Docker image from the pulled repository.
  - **Push Docker image**: Pushes the image to DockerHub (you can change this to push to Amazon ECR if desired).
  - **Deploy to EC2**: Uses SSH to connect to the EC2 instance, pull the latest Docker image, stop any running containers, and start the new container.

#### **Configure Jenkins with DockerHub Credentials**

1. In Jenkins, go to **Manage Jenkins** -> **Manage Credentials**.
2. Add DockerHub credentials using your DockerHub username and password. The credentials ID should match the `DOCKERHUB_CREDENTIALS` used in the Jenkinsfile.

#### **Configure SSH Credentials in Jenkins**

1. In Jenkins, go to **Manage Jenkins** -> **Manage Credentials** -> **Add Credentials**.
2. Add the private key associated with the EC2 key pair. This allows Jenkins to SSH into the EC2 instances where the application is running.

---

### **Step 6: Additional Enhancements and Scaling**

#### **6.1 Auto Scaling for Application EC2 Instances**

We can configure an **Auto Scaling Group (ASG)** for the EC2 instances running the application to ensure that they scale based on load.

```hcl
resource "aws_launch_configuration" "app_lc" {
  name          = "app-launch-configuration"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_pair_name

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install docker -y
              sudo service docker start
              docker pull your-dockerhub-username/resource-monitoring-app:latest
              docker run -d -p 80:80 your-dockerhub-username/resource-monitoring-app:latest
              EOF

  security_groups = [module.vpc_primary.security_group_id]
}

resource "aws_autoscaling_group" "app_asg" {
  launch_configuration = aws_launch_configuration.app_lc.id
  min_size             = 2
  max_size             = 5
  desired_capacity     = 2
  vpc_zone_identifier  = [module.vpc_primary.public_subnet_id]

  tag {
    key                 = "Name"
    value               = "resource-monitoring-app-instance"
    propagate_at_launch = true
  }
}
```

- **Explanation**:
  - **Launch Configuration**: Defines how new EC2 instances will be launched. The `user_data` script automatically pulls and runs the latest Docker container on launch.
  - **Auto Scaling Group (ASG)**: Ensures that there are always 2 running instances, and can scale up to 5 instances based on load.

#### **6.2 Route 53 Health Checks for Failover**

We can configure **Route 53 health checks** to monitor the health of the EC2 instances running the application. If an instance becomes unhealthy, Route 53 can automatically failover to another instance.

```hcl
resource "aws_route53_health_check" "app_health_check" {
  fqdn                          = var.app_domain_name
  port                          = 80
  type                          = "HTTP"
  resource_path                 = "/"
  failure_threshold             = 3
  request_interval              = 30
  health_threshold              = 2
}

resource "aws_route53_record" "app_dns" {
  zone_id = aws_route53_zone.app_zone.zone_id
  name    = var.app_domain_name
  type    = "A"

  alias {
    name                   = aws_lb.app_load_balancer.dns_name
    zone_id                = aws_lb.app_load_balancer.zone_id
    evaluate_target_health = true
  }

  health_check_id = aws_route53_health_check.app_health_check.id
}
```

- **Explanation**:
  - **Health Check**: Monitors the health of your application by making HTTP requests to the `/` endpoint.
  - **DNS Record**: Associates your domain with the Load Balancer’s DNS name and uses the health check to determine failover behavior.

---

### **Final Terraform Project Structure**

Here’s the full project structure with Jenkins, Docker, Auto Scaling, and Route 53 failover:

```
/resource-monitoring-app/
  ├── main.tf                # Main entry point for the infrastructure
  ├── variables.tf           # Variables file
  ├── outputs.tf             # Outputs for critical resources
  ├── provider.tf            # AWS provider configuration
  ├── terraform.tfvars       # Variable values for different environments
  ├── /modules/              # Reusable modules for VPC, EC2, RDS, etc.
  │    ├── vpc/
  │    │    ├── main.tf      # VPC resources
  │    │    ├── variables.tf
  │    │    ├── outputs.tf
  │    ├── ec2/
  │    │    ├── main.tf      # EC2 instance setup
  │    │    ├── variables.tf
  │    │    ├── outputs.tf
  │    ├── rds/
  │    │    ├── main.tf      # RDS configuration
  │   
     │    ├── variables.tf
  │    │    ├── outputs.tf
  └── /jenkins/
        ├── main.tf          # Jenkins instance with Docker setup
        ├── variables.tf
        ├── outputs.tf
```

---

### **Next Steps**

1. **Scaling**: You can implement further scaling policies for your Auto Scaling Group based on CPU, memory, or application-specific metrics.
2. **CI/CD Pipeline Optimization**: Automate more parts of the Jenkins pipeline, such as automated rollback on failures.
3. **Security Hardening**: Consider adding security layers such as AWS WAF for web traffic filtering, SSL termination with Load Balancers, and IAM policies with least privilege.

---

# **Implementation**:

Now, let’s walk through how to implement the same infrastructure and deploy the **System Resource Monitoring Web App** using **Terraform**. Terraform is an Infrastructure as Code (IaC) tool that allows you to automate infrastructure setup and management.

Here, I’ll provide detailed **step-by-step instructions** to set up your infrastructure with Terraform, write the necessary code snippets, and explain why each component is required.

---

### **Phase 1: Install Terraform and AWS CLI**

Before starting, ensure that you have Terraform and AWS CLI installed on your machine.

#### **Step 1: Install Terraform**
- Follow instructions from the official Terraform website: [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli).

#### **Step 2: Install AWS CLI**
- Follow instructions from the official AWS documentation: [Install AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html).

#### **Step 3: Configure AWS CLI**
Run the following command to configure AWS credentials:
```bash
aws configure
```
Provide your AWS **Access Key**, **Secret Key**, and **Region** to configure your environment.

---

### **Phase 2: Initialize the Project Directory**

1. Create a new directory for your Terraform project:
   ```bash
   mkdir resource-monitoring-app
   cd resource-monitoring-app
   ```

2. Inside the project directory, create a file named `main.tf`. This will be the primary configuration file where you define your infrastructure.

---

### **Phase 3: Define the AWS VPC, Subnets, and Networking**

In this phase, you will set up the **VPC**, **subnets**, **Internet Gateway**, **Route Tables**, and **Security Groups** to create a highly available network environment.

#### **Step 1: VPC and Subnet Configuration**
```hcl
provider "aws" {
  region = "us-west-2" # Change to your preferred region
}

resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "main_vpc"
  }
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet_a"
  }
}

resource "aws_subnet" "private_subnet_a" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-west-2a"
  tags = {
    Name = "private_subnet_a"
  }
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-west-2b"
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet_b"
  }
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-west-2b"
  tags = {
    Name = "private_subnet_b"
  }
}
```

- **Explanation**: 
  - The **VPC** serves as the isolated network where all resources are launched.
  - We create **two public and two private subnets** in different availability zones (`us-west-2a` and `us-west-2b`) for high availability.

#### **Step 2: Set Up Internet Gateway and Route Tables**
```hcl
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "main_igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public_rt_assoc_a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rt_assoc_b" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_rt.id
}
```

- **Explanation**: 
  - **Internet Gateway (IGW)** enables internet access for resources in public subnets.
  - **Route tables** are configured to direct traffic for public subnets to the Internet Gateway.

#### **Step 3: Security Group**
```hcl
resource "aws_security_group" "web_sg" {
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web_security_group"
  }
}
```

- **Explanation**: 
  - This **security group** allows inbound HTTP (port 80) and SSH (port 22) traffic, while allowing all outbound traffic. It is applied to EC2 instances for security.

---

### **Phase 4: EC2 Instances with Auto Scaling and Load Balancer**

#### **Step 1: Launch Configuration for EC2 Instances**
```hcl
resource "aws_launch_configuration" "app" {
  name          = "app-launch-configuration"
  image_id      = "ami-0c55b159cbfafe1f0" # Replace with your desired AMI
  instance_type = "t2.micro"
  associate_public_ip_address = true

  lifecycle {
    create_before_destroy = true
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install docker -y
              sudo service docker start
              sudo usermod -aG docker ec2-user
              docker run -d -p 80:80 swapnilyavalkar/system-resource-monitoring-web-app
              EOF

  security_groups = [aws_security_group.web_sg.id]

  iam_instance_profile = aws_iam_instance_profile.ec2_role_profile.name
}
```

- **Explanation**: 
  - This launch configuration sets up EC2 instances with **Docker** pre-installed and runs the **System Resource Monitoring Web App** container on startup.
  - The **user_data** script installs Docker and pulls the container from DockerHub, then starts the app.

#### **Step 2: Auto Scaling Group**
```hcl
resource "aws_autoscaling_group" "app_asg" {
  desired_capacity     = 2
  max_size             = 3
  min_size             = 1
  launch_configuration = aws_launch_configuration.app.id
  vpc_zone_identifier  = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]

  health_check_type = "EC2"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "resource-monitor-instance"
    propagate_at_launch = true
  }
}
```

- **Explanation**: 
  - **Auto Scaling Group (ASG)** ensures there are always at least 1 running instance and can scale up to 3 instances when demand increases.
  - The ASG spans across both public subnets for high availability.

#### **Step 3: Application Load Balancer**
```hcl
resource "aws_lb" "app_lb" {
  name               = "app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_sg.id]
  subnets            = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]
}

resource "aws_lb_target_group" "app_tg" {
  name     = "app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main_vpc.id
}

resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.app_asg.id
  alb_target_group_arn   = aws

}

```

Sure, let's continue with the **Load Balancer Target Group** and completing the **Auto Scaling Group attachment** to the target group. We'll then proceed to other necessary components.

#### **Step 4: Attach Auto Scaling Group to Load Balancer**
```hcl
resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.app_asg.id
  alb_target_group_arn   = aws_lb_target_group.app_tg.arn
}
```

- **Explanation**: 
  - This resource attaches the **Auto Scaling Group** to the **Application Load Balancer's target group**. This ensures that traffic routed to the load balancer is evenly distributed across the EC2 instances managed by the Auto Scaling Group.

---

### **Phase 5: IAM Roles for EC2 and S3 Access**

#### **Step 1: Create IAM Role for EC2**
```hcl
resource "aws_iam_role" "ec2_role" {
  name = "ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "ec2_policy" {
  name        = "ec2-policy"
  description = "Policy for EC2 access to CloudWatch and S3"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_role_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_policy.arn
}

resource "aws_iam_instance_profile" "ec2_role_profile" {
  name = "ec2-role-profile"
  role = aws_iam_role.ec2_role.name
}
```

- **Explanation**:
  - **IAM Role** allows EC2 instances to securely interact with other AWS services like **S3** and **CloudWatch**.
  - The **policy** provides the necessary permissions to read and write from S3, as well as to create logs in CloudWatch.
  - The **instance profile** is attached to the EC2 instances to assume the IAM role.

---

### **Phase 6: RDS for Database**

We'll set up an **Amazon RDS (PostgreSQL)** instance with **Multi-AZ** for high availability.

#### **Step 1: RDS Instance with Multi-AZ**
```hcl
resource "aws_db_instance" "app_db" {
  allocated_storage    = 20
  engine               = "postgres"
  instance_class       = "db.t3.micro"
  name                 = "appdb"
  username             = "admin"
  password             = "yourpassword"
  parameter_group_name = "default.postgres12"
  multi_az             = true
  storage_encrypted    = true
  skip_final_snapshot  = true

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "app-db"
  }
}
```

- **Explanation**:
  - **RDS PostgreSQL** is used as the database for persistent storage.
  - The **multi-AZ** configuration ensures high availability and automatic failover in case of an AZ failure.

---

### **Phase 7: S3 Bucket for Logs and Static Files**

#### **Step 1: Create an S3 Bucket**
```hcl
resource "aws_s3_bucket" "app_bucket" {
  bucket = "resource-monitoring-app-bucket"
  acl    = "private"
  
  tags = {
    Name = "resource-monitoring-app-bucket"
  }
}

resource "aws_s3_bucket_versioning" "app_bucket_versioning" {
  bucket = aws_s3_bucket.app_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
```

- **Explanation**:
  - **S3** is used for storing logs, backups, and static assets (like app logs).
  - **Versioning** is enabled to preserve different versions of files for better management and recovery.

---

### **Phase 8: Monitoring and Logging with CloudWatch**

#### **Step 1: CloudWatch Log Group**
```hcl
resource "aws_cloudwatch_log_group" "app_log_group" {
  name = "/ecs/resource-monitoring-app"
  retention_in_days = 30
}
```

- **Explanation**:
  - The **CloudWatch Log Group** stores application logs, ensuring that logs are centralized and retained for 30 days.

#### **Step 2: CloudWatch Alarms for EC2 Instances**
```hcl
resource "aws_cloudwatch_metric_alarm" "cpu_high_alarm" {
  alarm_name          = "cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Triggered when CPU exceeds 80% for 2 periods"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    InstanceId = aws_instance.web.id
  }
}
```

- **Explanation**:
  - This **CloudWatch Alarm** triggers when the CPU utilization exceeds 80% for two consecutive periods (120 seconds). It can notify you via SNS.

#### **Step 3: SNS for Notifications**
```hcl
resource "aws_sns_topic" "alerts" {
  name = "app-alerts"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = "your-email@example.com"
}
```

- **Explanation**:
  - **SNS (Simple Notification Service)** is used to send notifications (via email in this case) when an alarm is triggered.

---

### **Phase 9: CI/CD Pipeline with Jenkins (Optional)**

Since Jenkins would require a dedicated server, this step can be automated through Jenkins, or if you prefer a managed service, you can use **AWS CodePipeline**.

---

### **Terraform Final Step: Apply the Configuration**

1. **Initialize Terraform** in your project directory:
   ```bash
   terraform init
   ```

2. **Validate the configuration** to ensure everything is correct:
   ```bash
   terraform validate
   ```

3. **Apply the Terraform configuration**:
   ```bash
   terraform apply
   ```

4. **Review the output** and approve the apply operation.

---

### **Wrap-Up: Explanation of the Entire Terraform Setup**

- **VPC, Subnets, and Security Groups**: These components provide a secure, isolated networking environment for your EC2 instances, load balancers, and databases, ensuring high availability.
- **EC2 Auto Scaling and Load Balancer**: Ensures that the web app is fault-tolerant and scales to meet demand.
- **IAM Roles**: Securely grant EC2 instances permissions to interact with AWS services like S3 and CloudWatch.
- **RDS**: Provides a highly available, fault-tolerant database for the application.
- **S3**: Used for storing application logs, backups, and other static content.
- **CloudWatch**: Monitors infrastructure and application metrics, and provides logging and alerts for potential issues.

By following these steps, you've now set up a highly available, scalable, and fully monitored infrastructure on AWS using Terraform. If you have any questions or need more clarifications, feel free to ask!