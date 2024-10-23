# 08-Project - Ingress Example

- **What it is**: An API object that manages external access to services, typically HTTP/HTTPS.
- **Purpose**: It provides routing rules to direct incoming traffic to the appropriate services inside the cluster.
- **Why we use it**: To expose multiple services under a single IP with different paths or domains.
- **Real-life Example**: It’s like a “traffic controller” at a busy intersection, directing cars (requests) to the right lanes (services).

## How to Configure and Use with Pods

- **Create an Ingress Resource**:

     ```yaml
     apiVersion: networking.k8s.io/v1
     kind: Ingress
     metadata:
       name: nginx-ingress
     spec:
       rules:
       - host: myapp.local
         http:
           paths:
           - path: /
             pathType: Prefix
             backend:
               service:
                 name: nginx-service
                 port:
                   number: 80
     ```

- **Ensure Pod and Service Exist**: Pods should be running behind the service (`nginx-service`) that is routed by the Ingress.
