# 08-Project - Retry and Timeout Example

Retries and timeouts help to handle flaky commands and ensure the pipeline doesn’t run indefinitely.

## **Jenkinsfile Example: Retry and Timeout**

```groovy
pipeline {
    agent any

    stages {
        stage('Test with Retry') {
            steps {
                retry(3) {
                    sh 'npm run test'  // Retries up to 3 times if it fails
                }
            }
        }

        stage('Deploy with Timeout') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    sh './deploy.sh'  // Times out if not completed in 5 minutes
                }
            }
        }
    }
}
```

- **Hands-On**: Add retry logic to flaky commands and implement timeouts for long-running deployments.
