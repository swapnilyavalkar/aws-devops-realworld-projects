# 06-Project - ConfigMaps Example

- **What it is**: A key-value store to manage configuration data separately from containerized applications.
- **Purpose**: Decouples configuration from the application code, making deployments more flexible.
- **Why we use it**: It allows updating the configuration without rebuilding the container image.
- **Real-life Example**: It’s like a “settings file” on your computer that applications read to understand their configurations.

## How to Configure and Use with Pods

- **Create a ConfigMap**:

     ```yaml
     apiVersion: v1
     kind: ConfigMap
     metadata:
       name: app-config
     data:
       APP_COLOR: blue
       APP_MODE: production
     ```

- **Use ConfigMap as Environment Variables in a Pod**:

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
         - name: APP_COLOR
           valueFrom:
             configMapKeyRef:
               name: app-config
               key: APP_COLOR
     ```

- **Use ConfigMap as a Volume in a Pod**:

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
         - mountPath: /etc/config
           name: config-vol
       volumes:
       - name: config-vol
         configMap:
           name: app-config
     ```
