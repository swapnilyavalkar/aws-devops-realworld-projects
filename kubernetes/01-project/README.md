# 01-Project - Example

- **What it is**: The smallest deployable unit in Kubernetes, a pod represents one or more containers that run together.
- **Purpose**: It encapsulates a container or a set of containers to run a specific application or process.
- **Why we use it**: Pods ensure that containers in them share the same network namespace and can easily communicate.
- **Real-life Example**: Imagine a pod as a “delivery truck” containing different packages (containers) going to the same destination (running the same service).
- **How to create**:
  - Create a file pod.yaml with below contents:

     ```yaml
     apiVersion: v1
     kind: Pod
     metadata:
       name: nginx-pod
     spec:
       containers:
       - name: nginx
         image: nginx
     ```

  - **Deploy**:

    ```bash
    kubectl apply -f pod.yaml
    ```
