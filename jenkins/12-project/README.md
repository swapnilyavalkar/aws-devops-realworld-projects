# **Dynamic Agent Allocation**

Dynamic agents allow you to allocate different agents or containers based on the environment.

## **Jenkinsfile Example: Dynamic Agent Allocation**

```groovy
pipeline {
    agent { label 'master' }

    stages {
        stage('Build') {
            agent { label 'linux' }
            steps {
                echo 'Building on Linux agent...'
            }
        }

        stage('Test') {
            agent { docker { image 'node:16' } }
            steps {
                echo 'Testing inside a Docker container...'
                sh 'npm run test'
            }
        }
    }
}
```

- **Hands-On**: Implement different agents for various stages, such as Docker containers for testing and specific agents for building.
