# 04-Project - Jenkinsfile Example

## **Example 4: Pipeline with Environment Variables**

```groovy
pipeline {
    agent any

    environment {
        NODE_ENV = 'production'
        DOCKER_IMAGE = 'my-docker-image'
    }

    stages {
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $DOCKER_IMAGE .'
            }
        }

        stage('Run Tests') {
            steps {
                sh 'npm run test'
            }
        }
    }
}
```