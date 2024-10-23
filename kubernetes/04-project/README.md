# 04-Project - Namespaces Example

- **What it is**: A virtual cluster within Kubernetes that provides logical isolation for resources.
- **Purpose**: It helps in segregating environments (e.g., dev, test, prod) or teams.
- **Why we use it**: To organize resources and prevent naming conflicts.
- **Real-life Example**: It’s like having separate “rooms” in a house, where each room is for a different purpose (e.g., bedroom, kitchen), but all exist under the same roof.

## How to Configure and Use with Pods

- **Create a Namespace**:

     ```bash
     kubectl create namespace dev
     ```

- **Deploy Pods in a Namespace**:

     ```yaml
     apiVersion: v1
     kind: Pod
     metadata:
       name: nginx-pod
       namespace: dev
     spec:
       containers:
       - name: nginx
         image: nginx
     ```

- **View Resources in a Namespace**:

     ```bash
     kubectl get pods -n dev
     ```

- **Deploying Services in a Namespace**: Add `namespace: dev` to the service manifest to ensure it is in the same namespace as the pods.
