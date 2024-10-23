# 01-Project - Jenkinsfile Example

## **What is a Jenkinsfile?**

A **Jenkinsfile** is a text file that contains the **definition of a Jenkins pipeline**. It is written in a syntax based on **Groovy**, a Java-like scripting language. Jenkinsfiles can be used to automate the **build, test, and deployment** of your applications.

## **Types of Jenkins Pipelines**

1. **Declarative Pipeline**:
   - It uses a simpler, predefined syntax that is easy to read and write.
   - It is recommended for most Jenkins users because of its structure and clarity.

2. **Scripted Pipeline**:
   - It uses a more flexible, Groovy-based syntax that allows for complex logic.
   - It is less readable and more suited for advanced users.

In this guide, we'll primarily focus on the **Declarative Pipeline**.

## **Jenkinsfile Skeleton (Declarative Pipeline)**

Here’s a basic skeleton of a Declarative Jenkinsfile:

```groovy
pipeline {
    agent any  // Define where to run the pipeline

    stages {
        stage('Build') {
            steps {
                // Commands for building the app
                echo 'Building...'
            }
        }
        
        stage('Test') {
            steps {
                // Commands for testing the app
                echo 'Testing...'
            }
        }
        
        stage('Deploy') {
            steps {
                // Commands for deploying the app
                echo 'Deploying...'
            }
        }
    }

    post {
        always {
            // Actions to always run at the end (e.g., clean up)
            echo 'Cleaning up...'
        }
    }
}
```

## **Core Components of a Jenkinsfile**

### 1. **Agent**

- Defines where the pipeline should run.
- Can be `any`, a specific label, or even Docker containers.
- **Example**:

     ```groovy
     agent any  // Runs on any available agent
     
     // Specific agent
     agent { label 'ubuntu' }
     
     // Run in a Docker container
     agent {
         docker { image 'node:16-alpine' }
     }
     ```

### 2. **Stages**

- Represents different phases in the CI/CD pipeline (e.g., build, test, deploy).
- Contains multiple **stage blocks**.
- Each stage block contains a set of **steps** to perform specific tasks.
- **Example**:

     ```groovy
     stages {
         stage('Build') {
             steps {
                 echo 'Building...'
             }
         }
         stage('Test') {
             steps {
                 echo 'Testing...'
             }
         }
         stage('Deploy') {
             steps {
                 echo 'Deploying...'
             }
         }
     }
     ```

### 3. **Steps**

- Contains the actual commands to execute inside each stage.
- **Example**:

     ```groovy
     steps {
         sh 'npm install'  // Shell command to install Node.js dependencies
         sh 'npm run test' // Shell command to run tests
     }
     ```

### 4. **Post**

- Defines actions to run after the pipeline completes (like clean-up, notifications, etc.).
- Has different options: `always`, `success`, `failure`, `unstable`, etc.
- **Example**:

     ```groovy
     post {
         success {
             echo 'Build was successful!'
         }
         failure {
             echo 'Build failed!'
         }
     }
     ```

## **Jenkinsfile Best Practices**

1. **Keep It Simple**: Start with a simple Jenkinsfile and add complexity as needed. A well-structured pipeline is easier to maintain.
2. **Use Environment Variables**: Define variables at the top to make your pipeline more configurable and easier to manage.
3. **Leverage Docker**: Use Docker containers to create isolated and consistent build environments.
4. **Use `when` Conditions**: Control when stages run based on conditions (e.g., specific branches, tags, etc.).
5. **Use Shared Libraries**: For complex pipelines, use [Jenkins Shared Libraries](https://www.jenkins.io/doc/book/pipeline/shared-libraries/) to reuse code across pipelines.
6. **Add Notifications**: Integrate Slack, email, or other notifications in the `post` block to keep the team updated on build results.

## **Hands-On Jenkinsfile Examples**

### **Example 1: Basic Node.js CI Pipeline**

```groovy
pipeline {
    agent any

    stages {
        stage('Install') {
            steps {
                sh 'npm install'
            }
        }

        stage('Build') {
            steps {
                sh 'npm run build'
            }
        }

        stage('Test') {
            steps {
                sh 'npm run test'
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
```
