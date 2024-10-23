# 07-Project - Secrets Example

- **What it is**: A Kubernetes object used to store sensitive information, such as passwords, OAuth tokens, and SSH keys.
- **Purpose**: Ensures that sensitive data is stored securely and can be accessed by the pods when needed.
- **Why we use it**: For managing sensitive data securely within deployments.
- **Real-life Example**: It’s like a “locked safe” containing the keys (credentials) required to access protected areas (secure apps).

## How to Configure and Use with Pods

- **Create a Secret**:

     ```yaml
     apiVersion: v1
     kind: Secret
     metadata:
       name: db-secret
     type: Opaque
     data:
       username: YWRtaW4=    # base64-encoded 'admin'
       password: cGFzc3dvcmQ= # base64-encoded 'password'
     ```

- **Use Secret as Environment Variables in a Pod**:

     ```yaml
     apiVersion: v1
     kind: Pod
     metadata:
       name: nginx-pod
     spec:
       containers:
       - name: nginx
         image: nginx
         env:
         - name: DB_USERNAME
           valueFrom:
             secretKeyRef:
               name: db-secret
               key: username
     ```

- **Use Secret as a Volume in a Pod**:

     ```yaml
     apiVersion: v1
     kind: Pod
     metadata:
       name: nginx-pod
     spec:
       containers:
       - name: nginx
         image: nginx
         volumeMounts:
         - mountPath: "/etc/secrets"
           name: secret-vol
       volumes:
       - name: secret-vol
         secret:
           secretName: db-secret
     ```
