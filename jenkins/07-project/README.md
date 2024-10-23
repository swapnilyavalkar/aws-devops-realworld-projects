# 07-Project - Advanced `when` Conditions Example

`when` allows you to define conditions under which stages run, making the pipeline more dynamic.

## **Jenkinsfile Example: Advanced `when` Conditions**

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

        stage('Deploy to Staging') {
            when {
                branch 'development'
            }
            steps {
                echo 'Deploying to Staging...'
            }
        }

        stage('Deploy to Production') {
            when {
                allOf {
                    branch 'master'
                    environment name: 'DEPLOY_ENV', value: 'production'
                }
            }
            steps {
                echo 'Deploying to Production...'
            }
        }
    }
}
```

- **Hands-On**: Implement more complex conditions such as deploying to production only when both the branch is `master` and the `DEPLOY_ENV` is set to `production`.