# 11-Project - ReplicaSets Example

- **What it is**: Ensures that a specified number of pod replicas are running at any time.
- **Purpose**: Helps in scaling pods and ensuring that a set number of replicas are maintained.
- **Why we use it**: While deployments manage rollouts, ReplicaSets ensure the desired number of replicas.
- **Real-life Example**: It’s like having “backup staff” in a restaurant, ensuring that there are always three waiters on duty, even if one takes a break.
- **How to create**:

     ```yaml
     apiVersion: apps/v1
     kind: ReplicaSet
     metadata:
       name: nginx-replicaset
     spec:
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
     ```
