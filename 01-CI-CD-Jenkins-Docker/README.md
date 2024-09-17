# CI/CD pipeline using Jenkins and Docker

### Overview:

- **What we are doing**:
   - We are automating the build and deployment process using Jenkins to create Docker images and push them to a Docker registry. This ensures that code changes are automatically built, tested, and deployed in a seamless manner.
   
- **Why we are doing it**:
   - Automating CI/CD pipelines minimizes human error, speeds up deployment, and allows for rapid feedback on changes. Docker ensures the app runs consistently across environments, and Jenkins manages the automation.

---

### Step 1: Launch an EC2 Instance
1. **Navigate to AWS Console**: 
   - Go to the [EC2 Dashboard](https://console.aws.amazon.com/ec2/).
   - Click **Launch Instance**.

2. **Choose Ubuntu Server**:
   - In the instance wizard, select **Ubuntu Server 22.04 LTS** (or the latest version).

3. **Instance Type**:
   - Select **t2.micro** for the free tier or a higher type based on your need.

4. **Configure Security Group**:
   - Allow ports: 
     - **22** (SSH)
     - **8080** (Jenkins)
     - **3000** (Your application)
     - **80** (for web access)
     - **443** (if using HTTPS)
   
5. **Launch and SSH into the Instance**:
   - Use your SSH key to access the instance:
     ```bash
     ssh -i "your-key.pem" ubuntu@your-ec2-public-ip
     ```

### Step 2: Install Docker and Jenkins
1. **Update the Instance**:
   ```bash
   sudo apt-get update
   sudo apt-get upgrade -y
   ```

2. **Install Docker**:
   ```bash
   sudo apt install docker.io -y
   sudo systemctl start docker
   sudo systemctl enable docker
   sudo usermod -aG docker ubuntu
   ```

3. **Install Jenkins**:
   ```bash
   sudo apt update
   sudo apt install openjdk-11-jdk -y
   wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
   sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
   sudo apt update
   sudo apt install jenkins -y
   ```

4. **Start Jenkins**:
   ```bash
   sudo systemctl start jenkins
   sudo systemctl enable jenkins
   ```

5. **Access Jenkins**:
   - Open your browser and navigate to `http://your-ec2-public-ip:8080`.
   - Follow the on-screen instructions to unlock Jenkins (use the password found at `/var/lib/jenkins/secrets/initialAdminPassword`).

### Step 3: Install Plugins in Jenkins
1. **Install Required Plugins**:
   - From the Jenkins dashboard, go to **Manage Jenkins** > **Manage Plugins**.
   - Install the following plugins:
     - **Docker Pipeline Plugin**
     - **GitHub Plugin**
     - **Pipeline Plugin**

### Step 4: Configure Jenkins with Docker
1. **Add Docker to Jenkins**:
   - Go to **Manage Jenkins** > **Global Tool Configuration**.
   - Under **Docker** > **Add Docker**, point it to your Docker installation:
     ```bash
     /usr/bin/docker
     ```

2. **Create Jenkins Pipeline**:
   - In Jenkins, click **New Item**, choose **Pipeline**, and name it (e.g., `docker-cicd`).
   - Add the pipeline script with the following stages:
     ```groovy
     pipeline {
         agent any
         stages {
             stage('Clone Repository') {
                 steps {
                     git 'https://github.com/swapnilyavalkar/your-repo'
                 }
             }
             stage('Build Docker Image') {
                 steps {
                     script {
                         docker.build('yourdockerhubusername/ci-cd-jenkins-docker-app')
                     }
                 }
             }
             stage('Push Docker Image') {
                 steps {
                     script {
                         docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-credentials') {
                             docker.image('yourdockerhubusername/ci-cd-jenkins-docker-app').push('latest')
                         }
                     }
                 }
             }
         }
     }
     ```

3. **Run the Pipeline**:
   - After setting up the pipeline, trigger a build and ensure the code is cloned, the Docker image is built, and it is pushed to Docker Hub.

### Step 5: Deploy the Application Using Docker
1. **Pull and Run the Docker Image**:
   - After the build, you can pull the image and run the app on any server:
     ```bash
     docker pull yourdockerhubusername/ci-cd-jenkins-docker-app
     docker run -d -p 3000:3000 yourdockerhubusername/ci-cd-jenkins-docker-app
     ```

2. **Access the Application**:
   - Open `http://your-ec2-public-ip:3000` to view the deployed app.

---