# **Customer Application Deployment on Kubernetes with Terraform, Ansible, and CI/CD**

## **Overview**

This project involves deploying a Maven-based Java application on AWS EC2 instances and Kubernetes using Terraform for infrastructure provisioning, Ansible for configuration management, and GitLab CI/CD for continuous integration and deployment. Additionally, the project includes monitoring setup using Prometheus, Grafana, Loki, and New Relic, along with setting up an NGINX ingress controller for internet access.

### **Tools and Technologies Used:**
1. **Kubernetes** (Container orchestration)
2. **EC2 Instances** (AWS infrastructure)
3. **Terraform** (Infrastructure as code)
4. **Ansible** (Configuration management)
5. **GitLab** (CI/CD pipeline)
6. **Docker** (Containerization)
7. **Prometheus, Grafana, Loki** (Monitoring and logging)
8. **New Relic** (Application performance monitoring)
9. **NGINX Ingress Controller** (Internet exposure)

---

## **Project Structure and Implementation Stages**

### **Stage 1: Provision AWS Infrastructure using Terraform**

#### **What:**
Terraform is an Infrastructure-as-Code (IaC) tool that automates the provisioning of cloud infrastructure such as EC2 instances, VPCs, and networking resources.

#### **Why:**
Terraform allows you to manage your infrastructure declaratively, making it easier to automate deployments and manage changes.

#### **How:**

1. **Create a `main.tf` file** for Terraform to provision VPC, Subnet, Internet Gateway, Security Groups, and EC2 instances:

```hcl
provider "aws" {
  region = "ap-south-1"
}

# VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Main VPC"
  }
}

# Subnet
resource "aws_subnet" "main_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "Main Subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "Main IGW"
  }
}

# Security Group
resource "aws_security_group" "main_sg" {
  vpc_id = aws_vpc.main_vpc.id
  description = "Allow HTTP and SSH traffic"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
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
    Name = "Main SG"
  }
}

# EC2 Instance
resource "aws_instance" "main_instance" {
  ami           = "ami-0a91cd140a1fc148a" # Ubuntu AMI
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.main_subnet.id
  security_groups = [aws_security_group.main_sg.name]
  tags = {
    Name = "Main EC2 Instance"
  }
  key_name = "my-ssh-key"
}
```

2. **Initialize Terraform**:
   ```bash
   terraform init
   ```

3. **Plan the infrastructure deployment**:
   ```bash
   terraform plan
   ```

4. **Apply the changes to deploy resources**:
   ```bash
   terraform apply
   ```

---

### **Stage 2: Configure EC2 Instances using Ansible**

#### **What:**
Ansible is used to configure the EC2 instances, ensuring Docker and Kubernetes tools are installed and running.

#### **Why:**
Ansible automates the configuration of EC2 instances, reducing manual work and ensuring consistency across all nodes.

#### **How:**

1. **Create an `inventory.ini` file**:
   ```ini
   [all]
   <ec2-public-ip> ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/my-ssh-key
   ```

2. **Create a `playbook.yml` file** to automate Docker and Kubernetes installation on EC2 instances:

```yaml
---
- name: Setup EC2 instance
  hosts: all
  become: yes
  tasks:
    - name: Update and upgrade apt packages
      apt:
        update_cache: yes
        upgrade: dist

    - name: Install Docker
      apt:
        name: docker.io
        state: present

    - name: Start and enable Docker
      systemd:
        name: docker
        enabled: yes
        state: started

    - name: Add Kubernetes APT key
      apt_key:
        url: https://packages.cloud.google.com/apt/doc/apt-key.gpg
        state: present

    - name: Add Kubernetes APT repository
      apt_repository:
        repo: "deb http://apt.kubernetes.io/ kubernetes-xenial main"
        state: present

    - name: Install kubeadm, kubelet, and kubectl
      apt:
        name:
          - kubeadm
          - kubelet
          - kubectl
        state: present

    - name: Hold kubeadm, kubelet, and kubectl to prevent updates
      apt:
        name:
          - kubeadm
          - kubelet
          - kubectl
        state: hold

    - name: Pull the Kubernetes images required by kubeadm
      command: kubeadm config images pull
```

3. **Run the Ansible playbook**:
   ```bash
   ansible-playbook -i inventory.ini playbook.yml
   ```

---

### **Stage 3: Initialize, Configure Kubernetes Cluster, and Set Up NGINX Ingress**

#### **What:**
Kubernetes is a container orchestration tool that automates deployment, scaling, and management of containerized applications. The NGINX ingress controller helps in routing external HTTP(S) access to services running inside the cluster.

#### **Why:**
Kubernetes ensures high availability and scalability of applications. Integrating the NGINX ingress controller early in the configuration allows you to manage external traffic easily.

#### **How:**

1. **Install Docker** on each EC2 instance (if not done already):
   ```bash
   sudo apt-get update
   sudo apt-get install -y docker.io
   sudo systemctl enable docker
   sudo systemctl start docker
   ```

2. **Install kubeadm, kubelet, and kubectl** on each EC2 instance (if not done already):
   ```bash
   sudo apt-get update && sudo apt-get install -y apt-transport-https curl
   curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
   sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
   sudo apt-get install -y kubelet kubeadm kubectl
   sudo apt-mark hold kubelet kubeadm kubectl
   ```

3. **Initialize the Kubernetes cluster** on the master node:
   ```bash
   sudo kubeadm init --pod-network-cidr=192.168.0.0/16
   ```

4. **Set up the Kubernetes master node**:
   ```bash
   mkdir -p $HOME/.kube
   sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
   sudo chown $(id -u):$(id -g) $HOME/.kube/config
   ```

5. **Install a pod network (Weave)**:
   ```bash
   kubectl apply -f https://git.io/weave-kube
   ```

6. **Join worker nodes** to the cluster:
   Run the `kubeadm join` command on each worker node using the output from the master node’s initialization.

7. **Verify the Kubernetes cluster setup**:
   ```bash
   kubectl get nodes
   ```

8. **Install NGINX Ingress Controller using Helm**:
   ```bash
   helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
   helm repo update
   helm install nginx-ingress ingress-nginx/ingress-nginx --namespace ingress-nginx --create-namespace
   ```

9. **Expose the ingress controller using a LoadBalancer**:
   ```bash
   kubectl edit svc nginx-ingress-ingress-nginx-controller -n ingress-nginx
   ```

   Change the service type to `LoadBalancer`:
   ```yaml
   spec:
     type: LoadBalancer
   ```

10. **Create an ingress resource for your application**:
   Create a file called `app-ingress.yaml`:
   ```yaml
   apiVersion: networking.k8s.io/v1
   kind: Ingress
   metadata:
     name: my-app-ingress
     namespace: default
     annotations:
       nginx.ingress.kubernetes.io/rewrite-target: /
   spec:
     rules:
     - host: <your-domain-or-ip>
       http:
         paths:
         - path: /
           pathType: Prefix
           backend:
             service:
               name: my-java-app-service
               port:
                 number: 80
   ```

11. **Apply the ingress resource**:
   ```bash
   kubectl apply -f app-ingress.yaml
   ```

12. **Verify the ingress resource**:
   ```bash
   kubectl get ingress
   ```

13. **Access the application**:
   - If you are using a domain, you can access the application using `http://<your-domain>`.
   - If you are using the LoadBalancer external IP, you can access it using `http://<EXTERNAL-IP>`.

---

### **Stage 4: Dockerizing the Maven Application**

#### **What:**
We containerize the Maven application to run it as a Docker container, making it portable across environments.

#### **Why:**
Docker ensures that the application runs in a consistent environment, regardless of where it's deployed.

#### **How:**

1. **Create a Dockerfile** for your Maven application:

```Dockerfile
# Use an official OpenJDK runtime as a base image
FROM openjdk:11-jre-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the packaged jar file from the Maven build
COPY target/my-java-app-1.0-SNAPSHOT.jar my-java-app.jar

# Expose the port that the application will run on
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "my-java-app.jar"]
```

2. **Build the Docker image**:
   ```bash
   docker build -t <your-dockerhub-username>/my-java-app:latest .
   ```

3. **Push the Docker image** to Docker Hub:
   ```bash
   docker push <your-dockerhub-username>/my-java-app:latest
   ```

---

### **Stage 5: Deploy the Application on Kubernetes**

#### **What:**
We deploy the Dockerized Maven application on Kubernetes using a Deployment and Service configuration.

#### **Why:**
Kubernetes ensures high availability, scaling, and load balancing for your containerized application.

#### **How:**

1. **Create a Kubernetes deployment YAML file (`deployment.yaml`)**:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-java-app-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: my-java-app
  template:
    metadata:
      labels:
        app: my-java-app
    spec:
      containers:
      - name: my-java-app
        image: <your-dockerhub-username>/my-java-app:latest
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: my-java-app-service
spec:
  type: LoadBalancer
  selector:
    app: my-java-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
```

2. **Deploy the application** on Kubernetes:
   ```bash
   kubectl apply -f deployment.yaml
   ```

3. **Verify that the pods are running**:
   ```bash
   kubectl get pods
   ```

4. **Get the external IP address** of the LoadBalancer service to access the application:
   ```bash
   kubectl get services
   ```

5. **Access the application** via the external IP:
   ```
   http://<EXTERNAL-IP>/info
   ```

---

### **Stage 6: Configure GitLab CI/CD Pipeline**

#### **What:**
GitLab CI/CD automates the build, test, and deployment process of the Maven application using Docker and Kubernetes.

#### **Why:**
CI/CD ensures continuous integration and continuous delivery, allowing for quick and frequent releases.

#### **How:**

1. **Create a `.gitlab-ci.yml` file** to define the GitLab CI/CD pipeline:

```yaml
stages:
  - build
  - test
  - dockerize
  - deploy

build:
  stage: build
  script:
    - mvn clean install

test:
  stage: test
  script:
    - mvn test

dockerize:
  stage: dockerize
  script:
    - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_REF_SLUG .
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_REF_SLUG

deploy:
  stage: deploy
  script:
    - kubectl apply -f deployment.yaml
```

2. **Run the pipeline** in GitLab. It will automatically build the application, run tests, create the Docker image, and deploy it to Kubernetes.

---

### **Stage 7: Set Up Monitoring with Prometheus, Grafana, and Loki**

#### **What:**
We install Prometheus for collecting metrics, Grafana for visualizing the metrics, and Loki for logging.

#### **Why:**
Monitoring and logging are essential for tracking the performance, health, and activity of your application in real-time.

#### **How:**

1. **Install Prometheus and Grafana using Helm**:
   ```bash
   helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
   helm repo update
   helm install prometheus prometheus-community/prometheus
   helm install grafana grafana/grafana
   ```

2. **Install Loki for logging**:
   ```bash
   helm repo add grafana https://grafana.github.io/helm-charts
   helm install loki grafana/loki-stack
   ```

3. **Set up Grafana** to visualize Prometheus metrics and Loki logs.

---

### **Stage 8: Set Up New Relic for Application Performance Monitoring**

#### **What:**
New Relic provides Application Performance Monitoring (APM), helping track performance, CPU usage, memory usage, and more for your application.

#### **Why:**
Using New Relic allows you to track application health and performance in real-time, providing insights into system bottlenecks and performance optimizations.

#### **How:**

1. **Create a New Relic DaemonSet YAML file (`newrelic-daemonset.yaml`)**:

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: newrelic-agent
  labels:
    app: newrelic-agent
spec:
  selector:
    matchLabels:
      app: newrelic-agent
  template:
    metadata:
      labels:
        app: newrelic-agent
    spec:
      containers:
      - name: newrelic-agent
        image: newrelic/infrastructure-k8s:latest
        env:
        - name: NEW_RELIC_LICENSE_KEY
          value: "<your-new-relic-license-key>"
        - name: CLUSTER_NAME
          value: "my-k8s-cluster"
```

2. **Deploy the New Relic DaemonSet** on Kubernetes:
   ```bash
   kubectl apply -f newrelic-daemonset.yaml
   ```

3. **Monitor your application’s performance** using the New Relic dashboard.

---

### **Stage 9: Optional - SSL Configuration for HTTPS Access**

#### **What:**
SSL encryption ensures secure communication between your application and its users by using HTTPS.

#### **Why:**
Securing your application with HTTPS is essential for protecting sensitive data and ensuring user privacy.

#### **How:**

1. **Install Cert-Manager** to automate certificate management:
   ```bash
   kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.7.0/cert-manager.yaml
   ```

2. **Create a ClusterIssuer for Let's Encrypt**:
   Create a file called `letsencrypt-clusterissuer.yaml`:
   ```yaml
   apiVersion: cert-manager.io/v1
   kind: ClusterIssuer
   metadata:
     name: letsencrypt-prod
   spec:
     acme:
       server: https://acme-v02.api.letsencrypt.org/directory
       email: <your-email-address>
       privateKeySecretRef:
         name: letsencrypt-prod
       solvers:
       - http01:
           ingress:
             class: nginx
   ```

   Apply the issuer:
   ```bash
   kubectl apply -f letsencrypt-clusterissuer.yaml
   ```

3. **Update your ingress resource** to use SSL:
   Add the following annotations to your ingress resource:
   ```yaml
   metadata:
     annotations:
       cert-manager.io/cluster-issuer: letsencrypt-prod
   ```

   Add the `tls` section to your ingress resource:
   ```yaml
   spec:
     tls:
     - hosts:
       - myapp.mydomain.com
       secretName: myapp-tls
   ```

4. **Apply the updated ingress resource**:
   ```bash
   kubectl apply -f app-ingress.yaml
   ```

Once the certificate is provisioned, you can access your application securely using `https://myapp.mydomain.com`.