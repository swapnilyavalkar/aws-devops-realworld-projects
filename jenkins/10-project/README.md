# **Using Jenkins Shared Libraries**

Shared libraries allow you to reuse common code across multiple Jenkinsfiles.

## **Jenkinsfile Example: Using Shared Libraries**

1. **Define the shared library function in a Git repo (`vars/helloWorld.groovy`):**

   ```groovy
   def call() {
       echo 'Hello from the Shared Library!'
   }
   ```

2. **In the Jenkinsfile:**

   ```groovy
   @Library('my-shared-library') _

   pipeline {
       agent any

       stages {
           stage('Use Shared Library') {
               steps {
                   helloWorld()
               }
           }
       }
   }
   ```

- **Hands-On**: Create a shared library repo in Jenkins, define a simple function, and call it in your Jenkinsfile.
