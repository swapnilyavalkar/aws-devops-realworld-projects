# CI/CD Pipeline using Jenkins and Docker

---

### Overview:

- **What we are doing**:  
   We are automating the build and deployment process using Jenkins to create Docker images and push them to a Docker registry. This ensures that code changes are automatically built, tested, and deployed seamlessly using a Continuous Integration/Continuous Deployment (CI/CD) pipeline.

- **Why we are doing it**:  
   Automating CI/CD pipelines minimizes human error, speeds up deployment, and allows for rapid feedback on changes. Docker ensures the app runs consistently across environments, and Jenkins manages the automation.

- **Real-Life Use Case**:

   At **Spotify**, engineers frequently push updates to various microservices that power features like playlists, song recommendations, and user profiles. To ensure fast and reliable updates, Spotify uses a CI/CD pipeline powered by Jenkins and Docker. 

   - When developers push code to GitHub, Jenkins automatically pulls the code, builds a Docker image, runs tests, and pushes the image to Docker Hub.
   - The updated Docker images are then deployed to production, ensuring consistent environments across development, testing, and production.

   This automation allows Spotify to release new features and updates quickly while minimizing manual errors and ensuring a seamless user experience.

---

### Step 1: Launch an EC2 Instance

1. **Navigate to AWS Console**:  
   - Go to the [EC2 Dashboard](https://console.aws.amazon.com/ec2/).  
   - Click **Launch Instance**.

2. **Choose Ubuntu Server**:  
   - Select **Ubuntu Server 22.04 LTS** (or the latest version).

3. **Instance Type**:  
   - Select **t2.micro** for the free tier or a higher type based on your needs.

4. **Configure Security Group**:  
   - Allow the following ports:
     - **22** (SSH)
     - **8080** (Jenkins)
     - **3000** (Your application)
     - **80** (for web access)
     - **443** (if using HTTPS)

5. **Launch and SSH into the Instance**:  
   Use your SSH key to access the instance:
   ```bash
   ssh -i "your-key.pem" ubuntu@your-ec2-public-ip
   ```

---

### Step 2: Install Docker and Jenkins

1. **Update the Instance**:
   ```bash
   sudo apt-get update
   sudo apt-get upgrade -y # Optional
   ```

2. **Install Docker**:
   ```bash
   sudo apt install docker.io -y
   sudo systemctl start docker
   sudo systemctl enable docker
   sudo usermod -aG docker ubuntu
   ```

3. **Install Java and Jenkins**:
   ```bash
   sudo apt install fontconfig openjdk-21-jdk -y
   sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian/jenkins.io-2023.key
   echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
   sudo apt-get update
   sudo apt-get install jenkins -y
   sudo usermod -aG docker jenkins
   sudo systemctl restart jenkins
   ```

4. **Check Services**:
   ```bash
   java -version
   docker -v
   sudo systemctl status jenkins
   ```

5. **Access Jenkins**:
   - Open your browser and navigate to `http://your-ec2-public-ip:8080`.
   - Follow the on-screen instructions to unlock Jenkins (use the password found at `/var/lib/jenkins/secrets/initialAdminPassword`).

   ```bash
   sudo cat /var/lib/jenkins/secrets/initialAdminPassword
   ```

---

### Step 3: Install Plugins in Jenkins

1. **Install Required Plugins**:
   - From the Jenkins dashboard, go to **Manage Jenkins** > **Manage Plugins** > **Available Plugins**.
   - Install the following plugins:
     - **Docker**
     - **Docker Pipeline**
     - **GitHub**
     - **Pipeline**

---

### Step 4: Configure Docker in Jenkins

#### If Docker is on the Same Jenkins Server:
1. **Test Docker Connection**:  
   Use this command to test Docker's availability on the Jenkins server:
   ```bash
   curl --unix-socket /var/run/docker.sock http://localhost/version
   ```

   If successful, it will return Docker version details.

#### If Docker is on a Different Server:
1. **Connect Jenkins to Remote Docker**:  
   If Docker is on another server, you need to configure Jenkins to connect to Docker remotely via TCP.
   - First, enable Docker remote API on the Docker host:
     ```bash
     sudo vim /lib/systemd/system/docker.service
     ```
     Add the following line under the `[Service]` section:
     ```
     ExecStart=/usr/bin/dockerd -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock
     ```
     Then restart Docker:
     ```bash
     sudo systemctl daemon-reload
     sudo systemctl restart docker
     ```

2. **Test Remote Docker Connection**:  
   Use this command from the Jenkins server to ensure it can access Docker on the remote server:
   ```bash
   curl http://remote-docker-host-ip:2375/version
   ```

---

### Corrected Step 5: Add Docker Hub Credentials to Jenkins

1. **Create Docker Hub Access Token (Recommended)**:
   - Log in to your [Docker Hub account](https://hub.docker.com/).
   - Go to **Account Settings** > **Security** > **New Access Token**.
   - Create an access token, name it appropriately (e.g., `jenkins-token`), and copy the token.

2. **Add Docker Hub Access Token in Jenkins**:
   - Go to your Jenkins dashboard.
   - Click on **Manage Jenkins** > **Manage Credentials** > **Global Credentials**.
   - Click on **Add Credentials**.
   - **Kind**: Choose **Secret text**.
   - **Secret**: Paste the Docker Hub access token.
   - **ID**: Set it as `docker-hub-credentials`.
   - Click **Save**.

---

### Step 6: Configure Jenkins Agent for Docker

1. **Set Up Docker Agent in Jenkins**:
   - Go to **Manage Jenkins** > **Configure Clouds** > **Add a new cloud** > **Docker**.
   - Under **Docker Cloud details**, configure the following:
     - **Docker Host URI**: Set to `unix:///var/run/docker.sock` if Docker is local or `tcp://remote-docker-host-ip:2375` if Docker is remote.
     - **Credentials**: Select **docker-hub-credentials**.

2. **Configure Docker Agent Template (Optional)**:
   - Under the **Docker Cloud** section, click **Add Docker Template**.
   - **Labels**: Set a label (e.g., `docker-agent`).
   - **Docker Image**: Specify the image to use for the agent (e.g., `jenkins/jnlp-slave`).
   - Click **Save**.

---

### Step 7: Create Jenkins Pipeline for CI/CD

1. **Create Jenkins Pipeline**:
   - In Jenkins, click **New Item**, choose **Pipeline**, and name it (e.g., `docker-cicd`).
   - Add the pipeline script with the following stages:

     Make sure to update the branch to `main`:

     ```groovy
     pipeline {
         agent any
         stages {
             stage('Clone Repository') {
                 steps {
                     git branch: 'main', url: 'https://github.com/swapnilyavalkar/DynamicWeb-NodeApp.git'
                 }
             }
             stage('Build Docker Image') {
                 steps {
                     script {
                         docker.build('swapnilyavalkar/ci-cd-jenkins-docker-app')
                     }
                 }
             }
             stage('Push Docker Image') {
                 steps {
                     script {
                         docker.withRegistry('https://index.docker.io/v1/', 'docker-hub-credentials') {
                             docker.image('swapnilyavalkar/ci-cd-jenkins-docker-app').push('latest')
                         }
                     }
                 }
             }
         }
     }
     ```

---

### Step 8: Test the Setup with Echo Statements

1. **Testing with Echo**:
   Before building or pushing a Docker image, you can add an `echo` step to test if your stages are working properly.

   Add the following code to the pipeline:
   ```groovy
   stage('Test Stage') {
       steps {
           echo 'Testing Jenkins Docker CI/CD Pipeline setup!'
       }
   }
   ```

   This will print the message in the Jenkins console when the pipeline runs, confirming that the pipeline stages are being executed correctly.

---

### Step 9: Run the Pipeline

1. **Run the Pipeline**:
   - After setting up the pipeline, trigger a build. Ensure the code is cloned from the correct branch (`main`), the Docker image is built, and the image is pushed to Docker Hub.

2. **Pull and Run the Docker Image**:
   After the build, you can pull the image and run the app on any server:
   ```bash
   docker pull yourdockerhubusername/ci-cd-jenkins-docker-app
   docker run -d -p 3000:3000 yourdockerhubusername/ci-cd-jenkins-docker-app
   ```

3. **Access the Application**:
   Open `http://your-ec2-public-ip:3000` to view the deployed app.

---