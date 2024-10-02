# 08-full-stack-cicd-pipeline-jenkins-aws-codedeploy-nginx

## Overview
This project outlines a real-life implementation of a CI/CD pipeline using Jenkins, GitHub, AWS CodeDeploy, EC2 instances, and Nginx for traffic routing with both public and private load balancers. User traffic will flow from the external load balancer to Nginx servers in the public subnet, which will forward user requests to an internal load balancer, and then to the web application servers in the private subnet.

---

## 1. Architecture Overview

### Infrastructure Design:

- **VPC (Virtual Private Cloud):**
  - **Public Subnet:**
    - Jenkins Server for CI/CD.
    - 2 Nginx Servers to route traffic from the external load balancer to the internal load balancer.
    - External Application Load Balancer for handling incoming user traffic.
    - NAT Gateway for providing internet access to the instances in the private subnet.
  - **Private Subnet:**
    - Internal Application Load Balancer for routing traffic to web application servers.
    - EC2 Application Servers (deployed via AWS CodeDeploy) for hosting the application.

This setup ensures that external user requests are handled securely and are routed through an efficient load-balancing and proxy system using Nginx.

---

## 2. AWS Infrastructure Setup

### Step 1: Create a VPC and Subnets

#### Create a VPC:

1. Go to the AWS Management Console and navigate to **VPC**.
2. Click on **Create VPC**.
   - **Name tag:** MyVPC.
   - **IPv4 CIDR block:** 10.0.0.0/16.
3. Click **Create VPC**.

#### Create Subnets:

##### Public Subnet:

1. Go to **Subnets** > **Create subnet**.
   - **Name tag:** PublicSubnet.
   - **VPC:** Select MyVPC.
   - **Availability Zone:** Choose an AZ (e.g., us-east-1a).
   - **IPv4 CIDR block:** 10.0.1.0/24.
2. Click **Create subnet**.

##### Private Subnet:

1. Go to **Subnets** > **Create subnet**.
   - **Name tag:** PrivateSubnet.
   - **VPC:** Select MyVPC.
   - **Availability Zone:** Choose a different AZ (e.g., us-east-1b).
   - **IPv4 CIDR block:** 10.0.2.0/24.
2. Click **Create subnet**.

#### Enable Auto-Assign Public IP for Public Subnet:

1. Select the **PublicSubnet**.
2. Click on **Actions** > **Modify auto-assign IP settings**.
3. Check **Enable auto-assign public IPv4 address**.
4. Click **Save**.

---

### Step 2: Set Up Internet Gateway and NAT Gateway

#### Create an Internet Gateway:

1. Go to **Internet Gateways** > **Create internet gateway**.
   - **Name tag:** MyInternetGateway.
2. Click **Create internet gateway**.

#### Attach the Internet Gateway to the VPC:

1. Select **MyInternetGateway**.
2. Click **Actions** > **Attach to VPC**.
   - **Select MyVPC**.
3. Click **Attach internet gateway**.

#### Create Route Table for Public Subnet:

1. Go to **Route Tables** > **Create route table**.
   - **Name tag:** PublicRouteTable.
   - **VPC:** Select MyVPC.
2. Click **Create route table**.

#### Add a Route to the Internet Gateway:

1. Select **PublicRouteTable**.
2. Click **Routes** > **Edit routes**.
3. Click **Add route**.
   - **Destination:** 0.0.0.0/0.
   - **Target:** Select MyInternetGateway.
4. Click **Save routes**.

#### Associate the Public Subnet with the Public Route Table:

1. Click **Subnet associations** > **Edit subnet associations**.
2. Select **PublicSubnet**.
3. Click **Save associations**.

#### Create NAT Gateway in Public Subnet:

1. Go to **NAT Gateways** > **Create NAT Gateway**.
   - **Name tag:** MyNATGateway.
   - **Subnet:** Select PublicSubnet.
   - **Connectivity type:** Public.
   - **Elastic IP allocation ID:** Click **Allocate Elastic IP**.
2. Click **Allocate**, select the allocated Elastic IP, and click **Create NAT gateway**.

#### Create Route Table for Private Subnet:

1. Go to **Route Tables** > **Create route table**.
   - **Name tag:** PrivateRouteTable.
   - **VPC:** Select MyVPC.
2. Click **Create route table**.

#### Add a Route to the NAT Gateway:

1. Select **PrivateRouteTable**.
2. Click **Routes** > **Edit routes**.
3. Click **Add route**.
   - **Destination:** 0.0.0.0/0.
   - **Target:** Select the NAT Gateway (MyNATGateway).
4. Click **Save routes**.

#### Associate the Private Subnet with the Private Route Table:

1. Click **Subnet associations** > **Edit subnet associations**.
2. Select **PrivateSubnet**.
3. Click **Save associations**.

---

## 3. Set Up Jenkins in Public Subnet

### Step 1: Launch Jenkins Server

#### Launch an EC2 Instance for Jenkins:

1. Go to **EC2 Dashboard** > **Instances** > **Launch Instances**.
   - **Name and Tags:** JenkinsServer.
   - **AMI:** Select Amazon Linux 2 AMI (HVM), SSD Volume Type.
   - **Instance Type:** t3.medium (2 vCPU, 4 GB RAM).
   - **Key Pair:** Select or create a key pair to access the instance via SSH.
   - **Network Settings:**
     - **VPC:** Select MyVPC.
     - **Subnet:** Select PublicSubnet.
     - **Auto-assign Public IP:** Enabled.
   - **Firewall (Security Groups):**
     - Create a new security group:
       - **Security group name:** JenkinsSG.
       - **Inbound rules:**
         - Type: SSH; Protocol: TCP; Port Range: 22; Source: Your IP (for SSH access).
         - Type: Custom TCP; Protocol: TCP; Port Range: 8080; Source: 0.0.0.0/0 (for Jenkins web interface).
   - **Storage:** Use default (8 GB gp2).

2. Click **Launch Instance**.

#### Connect to the Jenkins Server via SSH:

Open your terminal and run:

```bash
ssh -i /path/to/your/keypair.pem ec2-user@<Public-IP-of-JenkinsServer>
```

#### Install Jenkins on the EC2 Instance:

1. **Update the system:**

```bash
sudo apt-get update -y
```

2. **Install Java (OpenJDK 17):**

```bash
apt-cache search openjdk | grep openjdk-17
sudo apt install openjdk-17-jdk -y
```

3. **Add Jenkins Repository:**

```bash
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" https://pkg.jenkins.io/debian binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
```

4. **Install Jenkins:**

```bash
sudo apt-get install jenkins -y
```

5. **Check Jenkins Service Status:**

```bash
sudo systemctl status jenkins
```

6. **Adjust the Firewall (if necessary):** Ensure port 8080 is open if you're using a firewall.

#### Access Jenkins Web Interface:

1. Open your web browser.
2. Navigate to `http://<Public-IP-of-JenkinsServer>:8080`.

#### Unlock Jenkins:

1. Retrieve the initial admin password:

```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

2. Copy the password and paste it into the Jenkins web interface.
3. Install Suggested Plugins.
4. Create Admin User: Set up your admin username and password.

---

## 4. Set Up EC2 Application Servers in Private Subnet

### Step 1: Launch EC2 Instances for Application

#### Launch EC2 Instances:

1. Go to **EC2 Dashboard** > **Instances** > **Launch Instances**.
   - **Name and Tags:** AppServer1 and AppServer2.
   - **AMI:** Select Amazon Linux 2 AMI.
   - **Instance Type:** t3.micro (1 vCPU, 1 GB RAM).
   - **Key Pair:** Select the same key pair used for Jenkins (or create a new one).
   - **Network Settings:**
     - **VPC:** Select MyVPC.
     - **Subnet:** Select PrivateSubnet.
     - **Auto-assign Public IP:** Disabled.
   - **Firewall (Security Groups):**
     - Create a new security group:
       - **Security group name:** AppServersSG.
       - **Inbound rules:**
         - Type: HTTP; Protocol: TCP; Port Range: 80; Source: InternalALBSG.
         - Type: SSH; Protocol: TCP; Port Range: 22; Source: JenkinsSG (for deployments).
   - **Storage:** Use default (8 GB gp2).

2. Click **Launch Instances**.

---

#### Install AWS CodeDeploy Agent on Each EC2 Instance:

Since these are in a private subnet, you need to use SSH agent forwarding via the Jenkins server or set up a bastion host. For simplicity, we'll assume you can connect via the Jenkins server.

```bash
ssh -i /path/to/your/keypair.pem ec2-user@<Public-IP-of-JenkinsServer>
ssh ec2-user@<Private-IP-of-AppServer1>
```

##### Install CodeDeploy Agent:

```bash
sudo apt-get update -y
sudo apt-get install ruby wget -y
wget https://aws-codedeploy-us-east-1.s3.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto
sudo systemctl start codedeploy-agent
sudo systemctl enable codedeploy-agent
sudo systemctl status codedeploy-agent
```

Repeat the installation for AppServer2.

---

## 5. Set Up AWS CodeDeploy

### Step 1: Create a CodeDeploy Application

#### Create a Service Role for CodeDeploy:

1. Go to **IAM** > **Roles** > **Create Role**.
   - **Trusted Entity:** AWS service.
   - **Use Case:** CodeDeploy.
   - **Permissions:** The policy AWSCodeDeployRole will be attached.
   - **Role Name:** CodeDeployServiceRole.
2. Click **Create Role**.

#### Create a CodeDeploy Application:

1. Go to **AWS CodeDeploy** in the AWS Console.
2. Click **Create application**.
   - **Application Name:** MyApp.
   - **Compute Platform:** EC2/On-premises.
3. Click **Create application**.

#### Create a Deployment Group:

1. In your application, go to **Deployment Groups** > **Create deployment group**.
   - **Deployment Group Name:** MyAppDeploymentGroup.
   - **Service Role:** Select CodeDeployServiceRole.
   - **Deployment Type:** In-place.
   - **Environment Configuration:**
     - **Amazon EC2 instances.**
     - **Tags:** Use tags to identify your application servers or select the instances directly.
     - Ensure that the IAM role attached to your EC2 instances has the necessary permissions.
   - **Deployment Settings:** Leave default settings or configure as per your requirements.

2. Click **Create deployment group**.

---

## 6. Deploy Your Application from GitHub Repository

### Step 1: Set Up Your GitHub Repository

#### Clone Your Repository:

Use my existing repository: https://github.com/swapnilyavalkar/dynamicweb-nodeapp.git

You can clone this repository to your repository and then use it for next stpes.

Ensure your application code is up-to-date.

#### Include AppSpec File and Deployment Scripts:

Create an `appspec.yml` file in the root of your repository:

```yaml
version: 0.0
os: linux
files:
  - source: /
    destination: /home/ubuntu/dynamicweb-nodeapp/web-app
hooks:
  AfterInstall:
    - location: scripts/install_dependencies.sh
      timeout: 300
      runas: root
    - location: scripts/start_server.sh
      timeout: 300
      runas: root
```

Create a `scripts` directory with the following scripts:

##### `install_dependencies.sh`:

```bash
#!/bin/bash
curl -sL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo apt-get install -y nodejs
```

##### `start_server.sh`:

```bash
#!/bin/bash
pkill node || true
cd /home/ec2-user/my-node-app
sudo apt install npm -y
node app.js > app.log 2>&1 &
```

Make sure the scripts are executable:

```bash
chmod +x scripts/install_dependencies.sh
chmod +x scripts/start_server.sh
```

Commit and push these files to your GitHub repository.

---

### Step 2: Configure Jenkins Job for Deployment

#### Install AWS CodeDeploy Plugin in Jenkins:

1. Go to **Manage Jenkins** > **Manage Plugins** > **Available**.
2. Search for **AWS CodeDeploy Plugin** and install it.

#### Create a New Jenkins Job:

1. Go to **New Item** > **Freestyle Project**.
   - **Project Name:** MyNodeAppDeployment.
2. Click **OK**.

#### Configure Source Code Management:

1. Select **Git**.
   - **Repository URL:** https://github.com/swapnilyavalkar/dynamicweb-nodeapp.git.
   - **Credentials:** Add your GitHub credentials if the repository is private.

#### Add Build Steps:

##### Execute Shell:

```bash
#!/bin/bash
zip -r MyNodeApp.zip * .[^.]*
```

#### Add Post-build Actions:

1. **Deploy an application to AWS CodeDeploy.**
   - **Application Name:** MyApp.
   - **Deployment Group:** MyAppDeploymentGroup.
   - **AWS Region:** Your region (e.g., us-east-1).
   - **AWS Credentials:** Add AWS credentials with permissions for CodeDeploy.
   - **Revision Location:**
     - **Source:** Workspace.
     - **Artifacts:** MyNodeApp.zip.

2. Save the Job Configuration.

---

## 7. Configure Nginx as Reverse Proxy for Traffic Routing

### Step 1: Launch Two Nginx Servers in Public Subnet

#### Launch EC2 Instances for Nginx Servers:

1. Go to **EC2 Dashboard** > **Instances** > **Launch Instances**.
   - **Name and Tags:** NginxServer1 and NginxServer2.
   - **AMI:** Select Amazon Linux 2 AMI.
   - **Instance Type:** t3.micro.
   - **Key Pair:** Use your existing key pair.
   - **Network Settings:**
     - **VPC:** MyVPC.
     - **Subnet:** PublicSubnet.
     - **Auto-assign Public IP:** Enabled.
   - **Security Group:**
     - Create a new security group:
       - **Security group name:** NginxSG.
       - **Inbound rules:**
         - Type: HTTP; Protocol: TCP; Port Range: 80; Source: 0.0.0.0/0.
         - Type: SSH; Protocol: TCP; Port Range: 22; Source: Your IP.

2. Click **Launch Instances**.

#### Install Nginx on Both Servers:

##### Connect to Each Nginx Server via SSH:

```bash
ssh -i /path/to/your/keypair.pem ec2-user@<Public-IP-of-NginxServer1>
```

##### Install Nginx:

```bash
sudo apt-get update -y
sudo apt-get install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx
```

---

### Step 2: Configure Nginx to Forward Traffic to Internal Load Balancer

#### Set Up the Internal Load Balancer First (see Step 8), then come back to configure Nginx.

1. Obtain the DNS Name of the Internal Load Balancer.

#### Edit Nginx Configuration:

1. Open the Nginx Configuration File:

```bash
sudo nano /etc/nginx/nginx.conf
```

2. Modify the `http` block to include the following:

```nginx
http {
    server {
        listen 80;
        server_name _;
        location / {
            proxy_pass http://<Internal-Load-Balancer-DNS>;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
```

Replace `<Internal-Load-Balancer-DNS>` with the actual DNS name of your internal load balancer.

#### Save and Exit the editor.

##### Restart Nginx:

```bash
sudo systemctl restart nginx
```

Repeat the configuration for NginxServer2.

---

## 8. Set Up Load Balancers

### Step 1: Internal Load Balancer (Private)

#### Create an Internal Application Load Balancer:

1. Go to **EC2 Dashboard** > **Load Balancers** > **Create Load Balancer**.
   - **Select:** Application Load Balancer.
   - **Name:** InternalALB.
   - **Scheme:** Internal.
   - **IP address type:** IPv4.
   - **Listeners:**
     - **Protocol:** HTTP.
     - **Port:** 80.
   - **Availability Zones:**
     - **VPC:** MyVPC.
     - **Subnets:** Select PrivateSubnet.

#### Security Group:

1. Create or select a security group (**InternalALBSG**) allowing HTTP traffic from **NginxSG**.

#### Configure Routing:

1. **Target Group:**
   - **Name:** AppServersTG.
   - **Target Type:** Instances.
   - **Protocol:** HTTP.
   - **Port:** 80.

2. **Register Targets:** Select your application instances (AppServer1 and AppServer2).

3. Create Load Balancer.

---

### Step 2: External Load Balancer (Public)

#### Create an External Application Load Balancer:

1. Go to **EC2 Dashboard** > **Load Balancers** > **Create Load Balancer**.
   - **Select:** Application Load Balancer.
   - **Name:** ExternalALB.
   - **Scheme:** Internet-facing.
   - **IP address type:** IPv4.
   - **Listeners:**
     - **Protocol:** HTTP.
     - **Port:** 80.
   - **Availability Zones:**
     - **VPC:** MyVPC.
     - **Subnets:** Select PublicSubnet.

#### Security Group:

1. Create or select a security group (**ExternalALBSG**) allowing HTTP traffic from **0.0.0.0/0**.

#### Configure Routing:

1. **Target Group:

**
   - **Name:** NginxServersTG.
   - **Target Type:** Instances.
   - **Protocol:** HTTP.
   - **Port:** 80.

2. **Register Targets:** Select your Nginx instances (NginxServer1 and NginxServer2).

3. Create Load Balancer.

---

## 9. Testing the Setup

#### Trigger a Build in Jenkins:

1. Go to your Jenkins job (**MyNodeAppDeployment**).
2. Click **Build Now**.
3. Monitor the build progress.

#### Verify Deployment in CodeDeploy:

1. Go to **AWS CodeDeploy** > **Deployments**.
2. Ensure that the deployment was successful.

#### Access the Application:

1. Open your web browser.
2. Navigate to `http://<DNS-Name-of-ExternalALB>`.
3. The request should flow:
   - **External ALB** → **Nginx Servers** → **Internal ALB** → **Application Servers**.
4. You should see your application running.

---

## 10. Resource Cleanup

To avoid unnecessary charges, delete the following resources when you're done:

- **EC2 Instances:** Jenkins server, Nginx servers, application servers.
- **Load Balancers:** ExternalALB, InternalALB.
- **NAT Gateway:** MyNATGateway.
- **Elastic IPs:** Release any allocated Elastic IPs.
- **VPC and Subnets:** If not needed, delete MyVPC and associated subnets.
- **CodeDeploy Application and Deployment Group.**
- **IAM Roles:** Remove roles created for CodeDeploy and EC2 instances if no longer needed.