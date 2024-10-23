# 02-Project - Deployments Example

- **What it is**: A controller that manages the lifecycle of pods by defining a desired state and making sure the actual state matches it.
- **Purpose**: Deployments help in scaling, rolling updates, and rollback of applications.
- **Why we use it**: To manage the state of applications efficiently.
- **Real-life Example**: Think of it as a “recipe manager” in a restaurant that ensures the correct number of meals (pods) are being prepared and served, adjusting the quantity when necessary.
- **How to create**:
  - Create a file deployment.yaml with below contents:

       ```yaml
       apiVersion: apps/v1
       kind: Deployment
       metadata:
         name: nginx-deployment
       spec:
         replicas: 2
         selector:
           matchLabels:
             app: nginx
         template:
           metadata:
             labels:
               app: nginx
           spec:
             containers:
             - name: nginx
               image: nginx
       ```

  - **Deploy**:

      ```bash
      kubectl apply -f deployment.yaml
      ```
