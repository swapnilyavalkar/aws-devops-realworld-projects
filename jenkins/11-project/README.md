# **Matrix Build for Multiple Environments**

The matrix build allows you to run a pipeline across multiple environments or configurations.

## **Jenkinsfile Example: Matrix Build**

```groovy
pipeline {
    agent any

    stages {
        stage('Matrix Build') {
            matrix {
                axes {
                    axis {
                        name 'NODE_VERSION'
                        values '14', '16'
                    }
                    axis {
                        name 'OS'
                        values 'ubuntu', 'alpine'
                    }
                }
                stages {
                    stage('Build') {
                        steps {
                            echo "Building on ${NODE_VERSION} and ${OS}..."
                            // Add build commands here
                        }
                    }
                }
            }
        }
    }
}
```

- **Hands-On**: Use matrix builds to test your application across different Node.js versions and operating systems.
