# 09-Project - Post Conditions for Notifications Example

Post conditions can be used to send notifications or perform clean-up actions based on the pipeline's success or failure.

## **Jenkinsfile Example: Post Conditions for Notifications**

```groovy
pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                echo 'Building...'
                sh 'npm run build'
            }
        }
    }

    post {
        success {
            echo 'Build succeeded!'
            // Add Slack or email notification here
        }
        failure {
            echo 'Build failed!'
            // Add failure notification here
        }
        always {
            echo 'Cleaning up workspace...'
            cleanWs()
        }
    }
}
```

- **Hands-On**: Configure Jenkins to send Slack or email notifications in the post condition blocks based on build status.