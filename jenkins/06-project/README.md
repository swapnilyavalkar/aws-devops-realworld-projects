# 06-Project - Using Parameters Example

Parameters allow you to pass dynamic inputs to the pipeline at runtime.

## **Jenkinsfile Example: Parameters**

```groovy
pipeline {
    agent any

    parameters {
        string(name: 'DEPLOY_ENV', defaultValue: 'staging', description: 'Deployment Environment')
        booleanParam(name: 'SKIP_TESTS', defaultValue: false, description: 'Skip running tests')
    }

    stages {
        stage('Build') {
            steps {
                echo "Building for environment: ${params.DEPLOY_ENV}"
                sh 'npm run build'
            }
        }

        stage('Test') {
            when {
                expression { return !params.SKIP_TESTS }
            }
            steps {
                echo 'Running tests...'
                sh 'npm run test'
            }
        }

        stage('Deploy') {
            steps {
                echo "Deploying to ${params.DEPLOY_ENV} environment..."
                // Deployment commands here
            }
        }
    }
}
```

- **Hands-On**: Add parameters to your Jenkinsfile to handle different environments (e.g., `staging`, `production`) or conditional steps like skipping tests.