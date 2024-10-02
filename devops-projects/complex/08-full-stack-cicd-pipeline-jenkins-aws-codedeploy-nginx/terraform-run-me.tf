# Provider definition
provider "aws" {
  region = "ap-south-1"
}

# Variables
variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr_1" {
  default = "10.0.1.0/24"
}

variable "public_subnet_cidr_2" {
  default = "10.0.3.0/24"
}

variable "private_subnet_cidr_1" {
  default = "10.0.2.0/24"
}

variable "private_subnet_cidr_2" {
  default = "10.0.4.0/24"
}

variable "private_subnet_cidr_3" {
  default = "10.0.5.0/24"
}

variable "private_subnet_cidr_4" {
  default = "10.0.6.0/24"
}

variable "instance_type" {
  default = "t2.micro"
}

# Create VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "MyVPC"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "MyInternetGateway"
  }
}

# Create Public Subnet 1 (AZ 1)
resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.public_subnet_cidr_1
  map_public_ip_on_launch = true
  availability_zone = "ap-south-1a"

  tags = {
    Name = "PublicSubnet1"
  }
}

# Create Public Subnet 2 (AZ 2)
resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.public_subnet_cidr_2
  map_public_ip_on_launch = true
  availability_zone = "ap-south-1b"

  tags = {
    Name = "PublicSubnet2"
  }
}

# Create Private Subnet 1 (AZ 1)
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.private_subnet_cidr_1
  availability_zone = "ap-south-1a"

  tags = {
    Name = "PrivateSubnet1"
  }
}

# Create Private Subnet 2 (AZ 1)
resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.private_subnet_cidr_2
  availability_zone = "ap-south-1a"

  tags = {
    Name = "PrivateSubnet2"
  }
}

# Create Private Subnet 3 (AZ 2)
resource "aws_subnet" "private_subnet_3" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.private_subnet_cidr_3
  availability_zone = "ap-south-1b"

  tags = {
    Name = "PrivateSubnet3"
  }
}

# Create Private Subnet 4 (AZ 2)
resource "aws_subnet" "private_subnet_4" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.private_subnet_cidr_4
  availability_zone = "ap-south-1b"

  tags = {
    Name = "PrivateSubnet4"
  }
}

# Create NAT Gateway Elastic IP
resource "aws_eip" "nat_eip" {
  tags = {
    Name = "NatEIP"
  }
}

# Create NAT Gateway in Public Subnet 1
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_1.id

  tags = {
    Name = "MyNATGateway"
  }
}

# Create Route Table for Public Subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "PublicRouteTable"
  }
}

# Associate Public Subnet 1 with Route Table
resource "aws_route_table_association" "public_route_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

# Associate Public Subnet 2 with Route Table
resource "aws_route_table_association" "public_route_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}

# Create Route Table for Private Subnets (with NAT)
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "PrivateRouteTable"
  }
}

# Associate Private Subnet 1 with Route Table
resource "aws_route_table_association" "private_route_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_route_table.id
}

# Associate Private Subnet 2 with Route Table
resource "aws_route_table_association" "private_route_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_route_table.id
}

# Associate Private Subnet 3 with Route Table
resource "aws_route_table_association" "private_route_3" {
  subnet_id      = aws_subnet.private_subnet_3.id
  route_table_id = aws_route_table.private_route_table.id
}

# Associate Private Subnet 4 with Route Table
resource "aws_route_table_association" "private_route_4" {
  subnet_id      = aws_subnet.private_subnet_4.id
  route_table_id = aws_route_table.private_route_table.id
}

# Security Group for Jenkins Server
resource "aws_security_group" "jenkins_sg" {
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # SSH access
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Jenkins web interface
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "JenkinsSG"
  }
}

# Launch Jenkins Server (EC2 Instance)
resource "aws_instance" "jenkins_instance" {
  ami           = "ami-0dee22c13ea7a9a67"  # Amazon Linux 2 AMI ID (update as needed)
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet_1.id
  key_name      = "my-key-pair-2"  # Update with your key pair
  security_groups = [aws_security_group.jenkins_sg.id]

  associate_public_ip_address = true  # Assign Elastic IP

  tags = {
    Name = "JenkinsServer"
  }

  # Install Jenkins on launch
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install openjdk-17-jdk -y
              sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
              echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" https://pkg.jenkins.io/debian binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
              sudo apt-get update
              sudo apt-get install jenkins -y
              sudo systemctl start jenkins
              sudo systemctl enable jenkins
              EOF
}

# Create Elastic IPs for Nginx Servers
resource "aws_eip" "nginx_eip_1" {}

resource "aws_eip" "nginx_eip_2" {}

# Security Group for Nginx Servers
resource "aws_security_group" "nginx_sg" {
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP traffic
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH access
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "NginxSG"
  }
}


# Security Group for Application Servers
resource "aws_security_group" "app_sg" {
  name   = "AppServerSG"
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]  # Allow traffic from within the VPC
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH access (adjust as needed)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "AppServerSG"
  }
}

# Application Servers (EC2 instances) in Private Subnets
resource "aws_instance" "app_server_1" {
  ami                    = "ami-0dee22c13ea7a9a67"
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private_subnet_1.id
  key_name               = "my-key-pair-2"  # Update with your key pair
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  tags = {
    Name      = "AppServer1"
    AppServer = "Production"
  }

  user_data = <<-EOF
    #!/bin/bash
    sudo apt-get update -y
    sudo apt-get install ruby wget -y
    wget https://aws-codedeploy-ap-south-1.s3.amazonaws.com/latest/install
    chmod +x ./install
    sudo ./install auto
    sudo systemctl start codedeploy-agent
    sudo systemctl enable codedeploy-agent
  EOF
}

resource "aws_instance" "app_server_2" {
  ami                    = "ami-0dee22c13ea7a9a67"
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private_subnet_3.id  # Different AZ
  key_name               = "my-key-pair-2"  # Update with your key pair
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  tags = {
    Name      = "AppServer2"
    AppServer = "Production"
  }

  user_data = <<-EOF
    #!/bin/bash
    sudo apt-get update -y
    sudo apt-get install ruby wget -y
    wget https://aws-codedeploy-ap-south-1.s3.amazonaws.com/latest/install
    chmod +x ./install
    sudo ./install auto
    sudo systemctl start codedeploy-agent
    sudo systemctl enable codedeploy-agent
  EOF
}

# Create Internal Load Balancer (Application Load Balancer)
resource "aws_lb" "internal_alb" {
  name               = "InternalALB"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.nginx_sg.id]
  subnets            = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_3.id]  # Use subnets in different AZs

  tags = {
    Name = "InternalALB"
  }
}

# Create External Load Balancer (Application Load Balancer)
resource "aws_lb" "external_alb" {
  name               = "ExternalALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.nginx_sg.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]

  tags = {
    Name = "ExternalALB"
  }
}

# Create Target Group for App Servers
resource "aws_lb_target_group" "app_servers_tg" {
  name     = "AppServersTG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id

  # Health check configuration (optional)
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200"
    path                = "/"
    protocol            = "HTTP"
  }
}

# Attach EC2 NGINX servers to external LB.
resource "aws_lb_target_group_attachment" "nginx_instance_1_attachment" {
  target_group_arn = aws_lb_target_group.nginx_servers_tg.arn
  target_id        = aws_instance.nginx_instance_1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "nginx_instance_2_attachment" {
  target_group_arn = aws_lb_target_group.nginx_servers_tg.arn
  target_id        = aws_instance.nginx_instance_2.id
  port             = 80
}



# Create Target Group for Nginx Servers
resource "aws_lb_target_group" "nginx_servers_tg" {
  name     = "NginxServersTG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id
}

# Attach App server EC2 servers to internal LB.
resource "aws_lb_target_group_attachment" "app_server_1_attachment" {
  target_group_arn = aws_lb_target_group.app_servers_tg.arn
  target_id        = aws_instance.app_server_1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "app_server_2_attachment" {
  target_group_arn = aws_lb_target_group.app_servers_tg.arn
  target_id        = aws_instance.app_server_2.id
  port             = 80
}


# Create Listener for External ALB
resource "aws_lb_listener" "external_alb_listener" {
  load_balancer_arn = aws_lb.external_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx_servers_tg.arn
  }
}



# Create Listener for Internal ALB
resource "aws_lb_listener" "internal_alb_listener" {
  load_balancer_arn = aws_lb.internal_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_servers_tg.arn
  }
}

# Launch Nginx Server 1 in Public Subnet 1
resource "aws_instance" "nginx_instance_1" {
  ami           = "ami-0dee22c13ea7a9a67"  # Amazon Linux 2 AMI ID (update as needed)
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public_subnet_1.id
  key_name      = "my-key-pair-2"  # Update with your key pair
  security_groups = [aws_security_group.nginx_sg.id]

  associate_public_ip_address = true  # Automatically assigns a public IP address

  tags = {
    Name = "NginxServer1"
  }

  # Install Nginx and configure it to forward traffic to internal load balancer
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install nginx -y
              sudo systemctl start nginx
              sudo systemctl enable nginx

              # Configure Nginx to forward traffic to the internal load balancer
              echo 'server {
                listen 80;
                location / {
                  proxy_pass http://${aws_lb.internal_alb.dns_name};
                  proxy_set_header Host $host;
                  proxy_set_header X-Real-IP $remote_addr;
                  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                  proxy_set_header X-Forwarded-Proto $scheme;
                }
              }' | sudo tee /etc/nginx/conf.d/default.conf

              sudo systemctl restart nginx
              EOF
}

# Associate Elastic IP with Nginx Server 1
resource "aws_eip_association" "nginx_eip_association_1" {
  instance_id   = aws_instance.nginx_instance_1.id
  allocation_id = aws_eip.nginx_eip_1.id
}

# Launch Nginx Server 2 in Public Subnet 2
resource "aws_instance" "nginx_instance_2" {
  ami           = "ami-0dee22c13ea7a9a67"  # Amazon Linux 2 AMI ID (update as needed)
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public_subnet_2.id
  key_name      = "my-key-pair-2"  # Update with your key pair
  security_groups = [aws_security_group.nginx_sg.id]

  associate_public_ip_address = true  # Automatically assigns a public IP address

  tags = {
    Name = "NginxServer2"
  }

  # Nginx installation and configuration to forward traffic to internal load balancer
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install nginx -y
              sudo systemctl start nginx
              sudo systemctl enable nginx

              # Configure Nginx to forward traffic to the internal load balancer
              echo 'server {
                listen 80;
                location / {
                  proxy_pass http://${aws_lb.internal_alb.dns_name};
                  proxy_set_header Host $host;
                  proxy_set_header X-Real-IP $remote_addr;
                  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                  proxy_set_header X-Forwarded-Proto $scheme;
                }
              }' | sudo tee /etc/nginx/conf.d/default.conf

              sudo systemctl restart nginx
              EOF
}

# Associate Elastic IP with Nginx Server 2
resource "aws_eip_association" "nginx_eip_association_2" {
  instance_id   = aws_instance.nginx_instance_2.id
  allocation_id = aws_eip.nginx_eip_2.id
}

# AWS CodeDeploy setup

# Create IAM role for CodeDeploy
resource "aws_iam_role" "codedeploy_service_role" {
  name = "CodeDeployServiceRole-tf"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "codedeploy.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })

   lifecycle {
    ignore_changes = [name]
  }
}

# Attach policies to the CodeDeploy role
resource "aws_iam_role_policy_attachment" "codedeploy_attach_policy" {
  role       = aws_iam_role.codedeploy_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

# Create CodeDeploy Application
resource "aws_codedeploy_app" "my_app" {
  name             = "MyApp"
  compute_platform = "Server"
}

# Create CodeDeploy Deployment Group
resource "aws_codedeploy_deployment_group" "my_deployment_group" {
  app_name               = aws_codedeploy_app.my_app.name
  deployment_group_name  = "MyAppDeploymentGroup"
  service_role_arn       = aws_iam_role.codedeploy_service_role.arn

  deployment_style {
    deployment_type   = "IN_PLACE"
    deployment_option = "WITH_TRAFFIC_CONTROL"
  }

  # Add the load balancer information
  load_balancer_info {
    target_group_info {
      name = aws_lb_target_group.app_servers_tg.name  # Reference to your target group for the app servers
    }
  }

  ec2_tag_set {
    ec2_tag_filter {
      key   = "AppServer"
      value = "Production"
      type  = "KEY_AND_VALUE"
    }
  }
}

# OUTPUT CODE STARTS HERE

# Output for VPC
output "vpc_details" {
  value = {
    name = aws_vpc.my_vpc.tags.Name
    id   = aws_vpc.my_vpc.id
    type = "VPC"
  }
  description = "Details of the VPC"
}

# Output for Public Subnets
output "public_subnet_details" {
  value = [
    {
      name = aws_subnet.public_subnet_1.tags.Name
      id   = aws_subnet.public_subnet_1.id
      type = "Subnet"
    },
    {
      name = aws_subnet.public_subnet_2.tags.Name
      id   = aws_subnet.public_subnet_2.id
      type = "Subnet"
    }
  ]
  description = "Details of the Public Subnets"
}

# Output for Private Subnets
output "private_subnet_details" {
  value = [
    {
      name = aws_subnet.private_subnet_1.tags.Name
      id   = aws_subnet.private_subnet_1.id
      type = "Subnet"
    },
    {
      name = aws_subnet.private_subnet_2.tags.Name
      id   = aws_subnet.private_subnet_2.id
      type = "Subnet"
    },
    {
      name = aws_subnet.private_subnet_3.tags.Name
      id   = aws_subnet.private_subnet_3.id
      type = "Subnet"
    },
    {
      name = aws_subnet.private_subnet_4.tags.Name
      id   = aws_subnet.private_subnet_4.id
      type = "Subnet"
    }
  ]
  description = "Details of the Private Subnets"
}

# Output for Internet Gateway
output "internet_gateway_details" {
  value = {
    name = aws_internet_gateway.igw.tags.Name
    id   = aws_internet_gateway.igw.id
    type = "Internet Gateway"
  }
  description = "Details of the Internet Gateway"
}

# Output for NAT Gateway
output "nat_gateway_details" {
  value = {
    name = aws_nat_gateway.nat_gateway.tags.Name
    id   = aws_nat_gateway.nat_gateway.id
    type = "NAT Gateway"
  }
  description = "Details of the NAT Gateway"
}

# Output for Elastic IP of NAT Gateway
output "nat_gateway_eip_details" {
  value = {
    id   = aws_eip.nat_eip.id
    type = "Elastic IP"
  }
  description = "Elastic IP for NAT Gateway"
}

# Output for Jenkins EC2 Instance
output "jenkins_instance_details" {
  value = {
    name = aws_instance.jenkins_instance.tags.Name
    id   = aws_instance.jenkins_instance.id
    type = "EC2 Instance"
  }
  description = "Details of the Jenkins EC2 instance"
}

# Output for Nginx Server 1
output "nginx_server_1_details" {
  value = {
    name = aws_instance.nginx_instance_1.tags.Name
    id   = aws_instance.nginx_instance_1.id
    type = "EC2 Instance"
  }
  description = "Details of Nginx Server 1"
}

# Output for Nginx Server 2
output "nginx_server_2_details" {
  value = {
    name = aws_instance.nginx_instance_2.tags.Name
    id   = aws_instance.nginx_instance_2.id
    type = "EC2 Instance"
  }
  description = "Details of Nginx Server 2"
}

# Output for Elastic IPs of Nginx Servers
output "nginx_server_1_eip_details" {
  value = {
    id   = aws_eip.nginx_eip_1.id
    type = "Elastic IP"
  }
  description = "Elastic IP for Nginx Server 1"
}

output "nginx_server_2_eip_details" {
  value = {
    id   = aws_eip.nginx_eip_2.id
    type = "Elastic IP"
  }
  description = "Elastic IP for Nginx Server 2"
}

# Output for External Load Balancer
output "external_load_balancer_details" {
  value = {
    name = aws_lb.external_alb.tags.Name
    id   = aws_lb.external_alb.id
    type = "Load Balancer"
  }
  description = "Details of the External Load Balancer"
}

# Output for Internal Load Balancer
output "internal_load_balancer_details" {
  value = {
    name = aws_lb.internal_alb.tags.Name
    id   = aws_lb.internal_alb.id
    type = "Load Balancer"
  }
  description = "Details of the Internal Load Balancer"
}

# Output for Target Group of Nginx Servers
output "nginx_target_group_details" {
  value = {
    name = aws_lb_target_group.nginx_servers_tg.name
    id   = aws_lb_target_group.nginx_servers_tg.id
    type = "Target Group"
  }
  description = "Details of the Target Group for Nginx Servers"
}

# Output for App Target Group
output "app_target_group_details" {
  value = {
    name = aws_lb_target_group.app_servers_tg.name
    id   = aws_lb_target_group.app_servers_tg.id
    type = "Target Group"
  }
}

# Output for CodeDeploy Application
output "codedeploy_app_details" {
  value = {
    name = aws_codedeploy_app.my_app.name
    id   = aws_codedeploy_app.my_app.id
    type = "CodeDeploy Application"
  }
}

# Output for CodeDeploy Deployment Group
output "codedeploy_deployment_group_details" {
  value = {
    name = aws_codedeploy_deployment_group.my_deployment_group.deployment_group_name
    id   = aws_codedeploy_deployment_group.my_deployment_group.id
    type = "CodeDeploy Deployment Group"
  }
}

# Output for Application EC2 Instance 1
output "app_server_1_details" {
  value = {
    name = aws_instance.app_server_1.tags.Name
    id   = aws_instance.app_server_1.id
    type = "EC2 Instance"
  }
  description = "Details of Application Server 1"
}

# Output for Application EC2 Instance 2
output "app_server_2_details" {
  value = {
    name = aws_instance.app_server_2.tags.Name
    id   = aws_instance.app_server_2.id
    type = "EC2 Instance"
  }
  description = "Details of Application Server 2"
}