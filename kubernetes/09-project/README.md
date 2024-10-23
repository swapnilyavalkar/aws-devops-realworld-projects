# 09-Project - DaemonSets Example

- **What it is**: Ensures that a copy of a pod runs on all or some of the nodes in the cluster.
- **Purpose**: Used for deploying system-level services like logging, monitoring, or storage management.
- **Why we use it**: To run a specific pod on every node, ensuring consistent system-wide operations.
- **Real-life Example**: It’s like installing “antivirus software” on every computer (node) in a network to ensure system security.

## How to Configure and Use

- **Create a DaemonSet**:

     ```yaml
     apiVersion: apps/v1
     kind: DaemonSet
     metadata:
       name: node-logger
     spec:
       selector:
         matchLabels:
           app: node-logger
       template:
         metadata:
           labels:
             app: node-logger
         spec:
           containers:
           - name: logger
             image: busybox
             command: [ "tail", "-f", "/var/log/node.log" ]
     ```
