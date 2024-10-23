# 03-Project - Jenkinsfile Example

## **Example 3: Multi-Branch Pipeline**

This pipeline can differentiate between `development` and `master` branches:

```groovy
pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                sh 'npm run build'
            }
        }

        stage('Deploy') {
            when {
                branch 'master'
            }
            steps {
                echo 'Deploying to production...'
                // Deployment commands here
            }
        }

        stage('Deploy Dev') {
            when {
                branch 'development'
            }
            steps {
                echo 'Deploying to development...'
                // Development deployment commands here
            }
        }
    }
}
```