# 03-Project - Services Example

- **What it is**: An abstraction that defines a set of pods and provides a stable endpoint for accessing them.
- **Purpose**: It ensures that users or other applications can consistently connect to the right set of pods, even if pods are replaced.
- **Why we use it**: Pods have dynamic IPs, but services maintain a stable IP to ensure connectivity.
- **Real-life Example**: A service is like a “reception desk” in a hotel—it routes guests (traffic) to the right rooms (pods), even when the room number changes.
- **How to create**:

     ```yaml
     apiVersion: v1
     kind: Service
     metadata:
       name: nginx-service
     spec:
       selector:
         app: nginx
       ports:
         - protocol: TCP
           port: 80
           targetPort: 80
       type: ClusterIP
     ```

- After applying above file use below command to get service endpoint.

    ```bash
    minikube service nginx-service
    ```
