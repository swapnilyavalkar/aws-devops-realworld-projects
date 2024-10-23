# 10-Project - StatefulSets Example

- **What it is**: A controller that manages the deployment and scaling of stateful applications.
- **Purpose**: Manages stateful pods that need persistent storage and stable network identities.
- **Why we use it**: It provides stable IDs and storage to applications like databases or message queues.
- **Real-life Example**: It’s like assigning “permanent seats” to employees in an office, ensuring everyone has a fixed workstation.

## How to Configure and Use

- **Create a StatefulSet**:

     ```yaml
     apiVersion: apps/v1
     kind: StatefulSet
     metadata:
       name: web
     spec:
       serviceName: "nginx"
       replicas: 3
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
             volumeMounts:
             - name: www
               mountPath: /usr/share/nginx/html
       volumeClaimTemplates:
       - metadata:
           name: www
         spec:
           accessModes: [ "ReadWriteOnce" ]
           resources:
             requests:
               storage: 1Gi
     ```
