# 04-ec2-autoscaling-loadbalancer

#### **Overview**

This project provides comprehensive, step-by-step instructions for setting up a cost-effective, highly available, and fault-tolerant web application on AWS using a single region. The setup includes creating a Virtual Private Cloud (VPC), configuring security groups, deploying EC2 instances running Ubuntu, setting up an Auto Scaling Group (ASG), and configuring an Application Load Balancer (ALB).

---

#### **Table of Contents**

1. [Prerequisites](#prerequisites)
2. [Step 1: Create a VPC and Subnets](#step-1-create-a-vpc-and-subnets)
3. [Step 2: Configure Security Groups](#step-2-configure-security-groups)
4. [Step 3: Create a Launch Template with Shell Scripting](#step-3-create-a-launch-template-with-shell-scripting)
5. [Step 4: Set Up an Auto Scaling Group](#step-4-set-up-an-auto-scaling-group)
6. [Step 5: Configure an Application Load Balancer](#step-5-configure-an-application-load-balancer)
7. [Step 6: Deploy and Test the Application](#step-6-deploy-and-test-the-application)

---

### **Prerequisites**

- **AWS Account:** Ensure you have an active AWS account with the necessary permissions to create and manage AWS resources.
- **Basic Knowledge:** Familiarity with AWS services like VPC, EC2, Auto Scaling, and Load Balancers.
- **Ubuntu Linux:** Basic understanding of Ubuntu commands and shell scripting.

---

### **Step 1: Create a VPC and Subnets**

1. **Create a VPC:**
   - **Navigate to VPC Dashboard:**
     - Log in to the AWS Management Console.
     - Navigate to **Services** > **VPC**.
   - **Create VPC:**
     - Click on **Your VPCs** in the left menu.
     - Click **Create VPC**.
     - **Name:** `WebApp-VPC`.
     - **IPv4 CIDR block:** `10.0.0.0/16`.
     - **Tenancy:** Default.
     - Click **Create VPC**.

2. **Create Subnets:**
   - **Create Subnet 1:**
     - In the VPC Dashboard, click **Subnets**.
     - Click **Create Subnet**.
     - **Name:** `WebApp-Subnet-1`.
     - **VPC:** Select `WebApp-VPC`.
     - **Availability Zone:** Choose your preferred AZ (e.g., `us-east-1a`).
     - **IPv4 CIDR block:** `10.0.1.0/24`.
     - Click **Create Subnet**.
   - **Create Subnet 2:**
     - Repeat the above steps.
     - **Name:** `WebApp-Subnet-2`.
     - **Availability Zone:** Choose a different AZ (e.g., `us-east-1b`).
     - **IPv4 CIDR block:** `10.0.2.0/24`.
     - Click **Create Subnet**.

3. **Create an Internet Gateway:**
   - **Navigate to Internet Gateways:**
     - In the VPC Dashboard, click **Internet Gateways**.
     - Click **Create Internet Gateway**.
     - **Name:** `WebApp-IGW`.
     - Click **Create Internet Gateway**.
   - **Attach Internet Gateway to VPC:**
     - Select `WebApp-IGW`.
     - Click **Actions** > **Attach to VPC**.
     - Select `WebApp-VPC`.
     - Click **Attach Internet Gateway**.

4. **Update Route Tables:**
   - **Navigate to Route Tables:**
     - In the VPC Dashboard, click **Route Tables**.
   - **Modify Main Route Table:**
     - Select the main route table associated with `WebApp-VPC`.
     - Click **Routes** > **Edit Routes**.
     - Click **Add Route**.
       - **Destination:** `0.0.0.0/0`.
       - **Target:** Select `WebApp-IGW`.
     - Click **Save Routes**.
   - **Associate Subnets:**
     - Ensure both subnets (`WebApp-Subnet-1` and `WebApp-Subnet-2`) are associated with this route table.

---

### **Step 2: Configure Security Groups**

1. **Create Security Group for EC2 Instances:**
   - **Navigate to Security Groups:**
     - In the VPC Dashboard, click **Security Groups**.
     - Click **Create Security Group**.
   - **Configure Security Group:**
     - **Name:** `WebServer-SG`.
     - **Description:** Security group for web servers.
     - **VPC:** `WebApp-VPC`.
     - **Inbound Rules:**
       - **SSH:** 
         - **Type:** SSH
         - **Protocol:** TCP
         - **Port Range:** 22
         - **Source:** Your IP (e.g., `203.0.113.0/24`) or `0.0.0.0/0` for testing (not recommended for production).
       - **HTTP:**
         - **Type:** HTTP
         - **Protocol:** TCP
         - **Port Range:** 80
         - **Source:** `0.0.0.0/0`
       - **HTTPS:**
         - **Type:** HTTPS
         - **Protocol:** TCP
         - **Port Range:** 443
         - **Source:** `0.0.0.0/0`
     - **Outbound Rules:**
       - **Allow all outbound traffic** (default).
     - Click **Create Security Group**.

2. **Create Security Group for Load Balancer:**
   - **Repeat the above steps:**
     - **Name:** `ALB-SG`.
     - **Description:** Security group for Application Load Balancer.
     - **Inbound Rules:**
       - **HTTP:** 
         - **Type:** HTTP
         - **Protocol:** TCP
         - **Port Range:** 80
         - **Source:** `0.0.0.0/0`
       - **HTTPS:**
         - **Type:** HTTPS
         - **Protocol:** TCP
         - **Port Range:** 443
         - **Source:** `0.0.0.0/0`
     - **Outbound Rules:**
       - **Allow all outbound traffic**.
     - Click **Create Security Group**.

---

### **Step 3: Create a Launch Template with Shell Scripting**

1. **Navigate to the EC2 Dashboard:**
   - Log in to the AWS Management Console.
   - Navigate to **Services** > **EC2**.

2. **Create a Launch Template:**
   - In the EC2 Dashboard, click **Launch Templates** in the left menu.
   - Click **Create Launch Template**.
   - **Launch Template Name:** `WebServer-LaunchTemplate`.
   - **Template Version Description:** `Initial version`.
   - **AMI ID:** Select the latest **Ubuntu Server 20.04 LTS** AMI.
     - *Example AMI ID (us-east-1):* `ami-0d5d9d301c853a04a`.
   - **Instance Type:** `t3.micro` (eligible for Free Tier).
   - **Key Pair:** Select an existing key pair or create a new one.
   - **Network Settings:**
     - **VPC:** `WebApp-VPC`.
     - **Subnet:** Select `WebApp-Subnet-1`.
     - **Auto-assign Public IP:** Enable.
   - **Security Groups:** Select `WebServer-SG`.
   - **User Data:** Add the following shell script to automate web server installation and configuration.

   ```bash
   #!/bin/bash
   sudo apt-get update -y
   sudo apt-get install -y apache2
   sudo systemctl start apache2
   sudo systemctl enable apache2
   echo "<h1>Welcome to the Web Server</h1>" | sudo tee /var/www/html/index.html
   ```

   - **Advanced Details:** Leave as default unless specific configurations are needed.
   - Click **Create Launch Template**.

---

### **Step 4: Set Up an Auto Scaling Group**

1. **Navigate to Auto Scaling Groups:**
   - In the EC2 Dashboard, click **Auto Scaling Groups** in the left menu.
   - Click **Create Auto Scaling Group**.

2. **Configure Auto Scaling Group:**
   - **Auto Scaling Group Name:** `WebServer-ASG`.
   - **Launch Template:** Select `WebServer-LaunchTemplate`.
   - **Version:** Select the latest version.
   - Click **Next**.

3. **Configure Network:**
   - **VPC:** `WebApp-VPC`.
   - **Availability Zones:** Select both `WebApp-Subnet-1` and `WebApp-Subnet-2`.
   - Click **Next**.

4. **Configure Group Size and Scaling Policies:**
   - **Desired Capacity:** `2`.
   - **Minimum Capacity:** `1`.
   - **Maximum Capacity:** `4`.
   - **Scaling Policies:** 
     - **Target Tracking Scaling Policy:** Default is average CPU utilization at 50%.
     - Adjust as needed based on application requirements.
   - Click **Next**.

5. **Configure Notifications (Optional):**
   - Set up notifications for scaling events if desired.
   - Click **Next**.

6. **Configure Tags (Optional):**
   - Add tags to organize and manage resources.
   - Click **Next**.

7. **Review and Create:**
   - Review all configurations.
   - Click **Create Auto Scaling Group**.

---

### **Step 5: Configure an Application Load Balancer**

1. **Navigate to Load Balancers:**
   - In the EC2 Dashboard, click **Load Balancers** in the left menu.
   - Click **Create Load Balancer**.
   - Select **Application Load Balancer** and click **Create**.

2. **Configure Load Balancer:**
   - **Name:** `WebApp-ALB`.
   - **Scheme:** **Internet-facing**.
   - **IP address type:** IPv4.
   - **Listeners:** 
     - **HTTP:** Port 80.
     - **HTTPS:** (Optional) Port 443.
   - **Availability Zones:** Select the VPC `WebApp-VPC` and both subnets `WebApp-Subnet-1` and `WebApp-Subnet-2`.
   - Click **Next: Configure Security Settings**.

3. **Configure Security Settings (For HTTPS):**
   - **HTTPS Listener:** If you added an HTTPS listener, configure an SSL certificate.
     - **Choose a certificate from ACM:** Request or import a certificate using AWS Certificate Manager.
   - Click **Next: Configure Security Groups**.

4. **Configure Security Groups:**
   - **Security Group:** Select `ALB-SG`.
   - Click **Next: Configure Routing**.

5. **Configure Routing:**
   - **Target Group:**
     - **Name:** `WebServer-TG`.
     - **Target Type:** **Instance**.
     - **Protocol:** **HTTP**.
     - **Port:** `80`.
     - **VPC:** `WebApp-VPC`.
   - **Health Checks:**
     - **Protocol:** HTTP.
     - **Path:** `/index.html`.
     - **Interval:** 30 seconds.
     - **Timeout:** 5 seconds.
     - **Healthy threshold:** 5.
     - **Unhealthy threshold:** 2.
   - Click **Next: Register Targets**.

6. **Register Targets:**
   - **Targets:** Select the instances launched by the Auto Scaling Group.
   - Click **Include as pending below**.
   - Click **Next: Review**.

7. **Review and Create:**
   - Review all configurations.
   - Click **Create Load Balancer**.

8. **Update Auto Scaling Group to Use ALB:**
   - Navigate back to **Auto Scaling Groups**.
   - Select `WebServer-ASG`.
   - Click **Edit**.
   - Under **Load balancing**, select `WebApp-ALB`.
   - Choose the target group `WebServer-TG`.
   - Click **Update**.

---

### **Step 6: Deploy and Test the Application**

1. **Access the Web Application:**
   - Locate the **DNS name** of the `WebApp-ALB` from the Load Balancers section.
   - Open a web browser and navigate to the DNS name.
   - You should see the message: **"Welcome to the Web Server"**.

2. **Verify Auto Scaling:**
   - **Initial Instances:** Confirm that there are 2 running EC2 instances in the Auto Scaling Group.
   - **Health Checks:** Ensure all instances pass the health checks.

3. **Test Load Balancer and Auto Scaling with Stress Utility:**
   - **Install the `stress` utility** on the EC2 instance to simulate CPU load:
   
     ```bash
     sudo apt update
     sudo apt install -y stress
     ```

   - **Increase CPU Load**:
     Use the `stress` utility to create high CPU usage and simulate a load on your EC2 instance. For example, to create a high CPU load on 4 cores for 5 minutes (300 seconds), run the following command on your EC2 instance:

     ```bash
     stress --cpu 4 --timeout 300
     ```

     This will utilize 4 CPU cores at 100% for 300 seconds (5 minutes). Adjust the `--cpu` and `--timeout` parameters according to your desired load.

   - **Check if Auto Scaling is Working**:
     - Monitor your EC2 instance metrics (such as CPU utilization) in the **Amazon CloudWatch** dashboard.
     - As the CPU load increases, observe if the auto-scaling group triggers the launch of additional EC2 instances.
     - **Access the application** multiple times or from different devices to ensure the load balancer distributes traffic evenly across the instances.

   - **After the stress test**, ensure that your auto-scaling group scales down the instances once the load reduces.