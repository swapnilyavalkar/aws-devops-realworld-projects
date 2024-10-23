# **Scripted Pipelines (Groovy-based)**

Scripted pipelines offer more flexibility and can handle complex logic using Groovy.

## **Jenkinsfile Example: Scripted Pipeline**

```groovy
node {
    try {
        stage('Build') {
            echo 'Building...'
            sh 'npm run build'
        }

        stage('Test') {
            echo 'Testing...'
            sh 'npm run test'
        }

        stage('Deploy') {
            echo 'Deploying...'
            sh './deploy.sh'
        }
    } catch (Exception e) {
        echo "Build failed: ${e.getMessage()}"
    } finally {
        echo 'Cleaning up...'
        cleanWs()
    }
}
```

- **Hands-On**: Write a scripted pipeline to understand Groovy-based logic and error handling.

### **Best Practices for Advanced Jenkinsfiles**

1. **Modularize Pipelines**: Use shared libraries and functions to keep Jenkinsfiles clean and DRY (Don't Repeat Yourself).
2. **Use Environment Variables**: Store sensitive information (like credentials) securely using Jenkins credentials.
3. **Integrate Quality Checks**: Add stages for code quality checks (e.g., linting, static code analysis).
4. **Use Parallel Stages**: Run independent tasks concurrently to reduce pipeline execution time.
5. **Handle Errors Gracefully**: Use try-catch blocks and post conditions to handle errors and ensure clean-ups.