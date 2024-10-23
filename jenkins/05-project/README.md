# 05-Project - Parallel Execution

## **Additional Learning Concepts for Jenkinsfiles**

1. **Parallel Stages**: Use parallel stages to run tasks concurrently, reducing overall pipeline execution time.
2. **Parameters**: Use build parameters to make pipelines dynamic and adaptable to different builds or deployments.
   - **Example**:

     ```groovy
     parameters {
         string(name: 'DEPLOY_ENV', defaultValue: 'staging', description: 'Deployment environment')
     }
     ```

3. **Retry and Timeout**: Add retry logic and timeouts to handle flaky steps or commands that may fail intermittently.
   - **Example**:

     ```groovy
     steps {
         retry(3) {
             sh 'npm run test'
         }
     }
     ```

### **Summary**

- **Jenkinsfiles** bring pipelines as code to Jenkins, enabling version control, flexibility, and reusability.
- You’ve covered the **Declarative Pipeline**, which is easier to start with and more structured.
- The examples show different use cases like **Node.js CI**, **Docker-based pipelines**, and **multi-branch deployment**.
- Best practices, additional concepts, and advanced features can help you write **robust and maintainable Jenkins pipelines**.

### **Advanced Jenkinsfile Concepts**

1. **Parallel Execution**
2. **Using Parameters**
3. **Advanced `when` Conditions**
4. **Retry and Timeout**
5. **Post Conditions for Notifications**
6. **Using Jenkins Shared Libraries**
7. **Matrix Build for Multiple Environments**
8. **Dynamic Agent Allocation**
9. **Scripted Pipelines** (Groovy-based)

Parallel execution allows multiple stages to run concurrently, improving pipeline speed.

## **Jenkinsfile Example: Parallel Stages**

```groovy
pipeline {
    agent any

    stages {
        stage('Build and Test in Parallel') {
            parallel {
                stage('Build') {
                    steps {
                        echo 'Building...'
                        sh 'npm run build'
                    }
                }
                stage('Test') {
                    steps {
                        echo 'Running Tests...'
                        sh 'npm run test'
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deploying...'
            }
        }
    }

    post {
        always {
            echo 'Pipeline completed.'
        }
    }
}
```

- **Hands-On**: Modify the above Jenkinsfile to run build and test jobs concurrently. This is useful for running independent tasks in parallel.
