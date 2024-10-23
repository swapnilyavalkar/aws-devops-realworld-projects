# 02-Project - Jenkinsfile Example

## **Example 2: Jenkinsfile with Docker Agent**

This example shows how to run the pipeline inside a Docker container:

```groovy
pipeline {
    agent {
        docker { 
            image 'node:16-alpine' 
            args '-u root'  // Run as root user to install packages
        }
    }

    stages {
        stage('Install Dependencies') {
            steps {
                sh 'npm install'
            }
        }

        stage('Test') {
            steps {
                sh 'npm run test'
            }
        }
    }

    post {
        always {
            echo 'Cleaning up...'
        }
    }
}
```