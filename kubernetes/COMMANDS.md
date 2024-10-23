# COMMANDS

## Here’s a comprehensive list of Kubernetes admin commands with explanations. These commands are primarily executed using `kubectl`, the Kubernetes command-line tool, which is used to manage and administer Kubernetes clusters

### 1. **General Commands**

#### Get Cluster Info

```bash
kubectl cluster-info
```

- **Explanation**: Displays the Kubernetes master and services' information to verify that the cluster is running.

#### Get Component Status

```bash
kubectl get componentstatuses
```

- **Explanation**: Shows the status of key cluster components like etcd, controller-manager, and scheduler to ensure they are healthy.

#### Check API Server Version

```bash
kubectl version
```

- **Explanation**: Displays the Kubernetes client and server version details.

#### View All Resources in All Namespaces

```bash
kubectl get all --all-namespaces
```

- **Explanation**: Lists all resources (pods, services, deployments, etc.) in all namespaces.

### 2. **Node Management**

#### List Nodes

```bash
kubectl get nodes
```

- **Explanation**: Shows a list of all nodes in the cluster along with their statuses.

#### Describe a Node

```bash
kubectl describe node <node-name>
```

- **Explanation**: Displays detailed information about a specific node, including resource usage, labels, and taints.

#### Cordon a Node

```bash
kubectl cordon <node-name>
```

- **Explanation**: Marks a node as unschedulable to prevent new pods from being scheduled on it (useful during maintenance).

#### Drain a Node

```bash
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data
```

- **Explanation**: Evicts all running pods from a node while preparing it for maintenance. It ignores DaemonSets and deletes emptyDir data.

#### Uncordon a Node

```bash
kubectl uncordon <node-name>
```

- **Explanation**: Makes a cordoned node schedulable again, allowing new pods to be scheduled on it.

### 3. **Pod Management**

#### List Pods

```bash
kubectl get pods
```

- **Explanation**: Displays a list of all pods in the default namespace.

#### List Pods in All Namespaces

```bash
kubectl get pods --all-namespaces
```

- **Explanation**: Lists all pods across all namespaces.

#### Describe a Pod

```bash
kubectl describe pod <pod-name>
```

- **Explanation**: Shows detailed information about a specific pod, including events, resource usage, and configurations.

#### Delete a Pod

```bash
kubectl delete pod <pod-name>
```

- **Explanation**: Deletes a specified pod. It will be rescheduled by its controller if applicable.

#### Execute a Command Inside a Pod

```bash
kubectl exec -it <pod-name> -- <command>
```

- **Explanation**: Executes a command inside a running pod container (e.g., `kubectl exec -it <pod-name> -- /bin/sh`).

#### Port-Forward to a Pod

```bash
kubectl port-forward <pod-name> <local-port>:<pod-port>
```

- **Explanation**: Forwards a local port to a port on the specified pod, useful for local testing.

#### Get Pod Logs

```bash
kubectl logs <pod-name>
```

- **Explanation**: Retrieves logs from a specified pod. Use `-f` to follow the logs.

### 4. **Service Management**

#### List Services

```bash
kubectl get services
```

- **Explanation**: Lists all services in the default namespace.

#### Describe a Service

```bash
kubectl describe service <service-name>
```

- **Explanation**: Displays detailed information about a specific service, such as endpoints and selectors.

#### Expose a Pod as a Service

```bash
kubectl expose pod <pod-name> --type=<type> --port=<port> --target-port=<target-port>
```

- **Explanation**: Exposes a pod as a service with specified type (`ClusterIP`, `NodePort`, `LoadBalancer`), port, and target port.

### 5. **Namespace Management**

#### List Namespaces

```bash
kubectl get namespaces
```

- **Explanation**: Lists all namespaces in the cluster.

#### Create a Namespace

```bash
kubectl create namespace <namespace-name>
```

- **Explanation**: Creates a new namespace.

#### Delete a Namespace

```bash
kubectl delete namespace <namespace-name>
```

- **Explanation**: Deletes a specified namespace and all resources within it.

### 6. **Deployment Management**

#### List Deployments

```bash
kubectl get deployments
```

- **Explanation**: Lists all deployments in the default namespace.

#### Describe a Deployment

```bash
kubectl describe deployment <deployment-name>
```

- **Explanation**: Shows detailed information about a specific deployment, including replica sets, strategy, and rollout status.

#### Scale a Deployment

```bash
kubectl scale deployment <deployment-name> --replicas=<number>
```

- **Explanation**: Scales the specified deployment to the desired number of replicas.

#### Rollout Status of a Deployment

```bash
kubectl rollout status deployment <deployment-name>
```

- **Explanation**: Checks the rollout status of a deployment to ensure successful deployment.

#### Rollback a Deployment

```bash
kubectl rollout undo deployment <deployment-name>
```

- **Explanation**: Rolls back a deployment to the previous revision.

### 7. **ConfigMap and Secret Management**

#### List ConfigMaps

```bash
kubectl get configmaps
```

- **Explanation**: Lists all ConfigMaps in the default namespace.

#### Describe a ConfigMap

```bash
kubectl describe configmap <configmap-name>
```

- **Explanation**: Displays detailed information about a specific ConfigMap.

#### Create a ConfigMap from a File

```bash
kubectl create configmap <configmap-name> --from-file=<file-path>
```

- **Explanation**: Creates a ConfigMap using data from a specified file.

#### List Secrets

```bash
kubectl get secrets
```

- **Explanation**: Lists all secrets in the default namespace.

#### Describe a Secret

```bash
kubectl describe secret <secret-name>
```

- **Explanation**: Shows detailed information about a specific secret.

#### Create a Secret from Literal

```bash
kubectl create secret generic <secret-name> --from-literal=<key>=<value>
```

- **Explanation**: Creates a secret using a specified key-value pair.

### 8. **Persistent Volume (PV) & Persistent Volume Claim (PVC) Management**

#### List Persistent Volumes

```bash
kubectl get pv
```

- **Explanation**: Lists all persistent volumes in the cluster.

#### List Persistent Volume Claims

```bash
kubectl get pvc
```

- **Explanation**: Lists all persistent volume claims in the default namespace.

#### Describe a Persistent Volume or PVC

```bash
kubectl describe pv <pv-name>
kubectl describe pvc <pvc-name>
```

- **Explanation**: Shows detailed information about a specified PV or PVC.

### 9. **Ingress Management**

#### List Ingresses

```bash
kubectl get ingresses
```

- **Explanation**: Lists all ingress resources in the default namespace.

#### Describe an Ingress

```bash
kubectl describe ingress <ingress-name>
```

- **Explanation**: Displays detailed information about a specific ingress resource.

### 10. **Resource Quota and Limits**

#### List Resource Quotas

```bash
kubectl get resourcequotas
```

- **Explanation**: Lists all resource quotas in the default namespace.

#### Describe a Resource Quota

```bash
kubectl describe resourcequota <quota-name>
```

- **Explanation**: Shows detailed information about a specific resource quota.

#### Apply Resource Limits

```bash
kubectl apply -f <resource-quota-file>
```

- **Explanation**: Applies resource limits specified in a YAML file to the cluster.

### 11. **Role-Based Access Control (RBAC)**

#### List Roles and RoleBindings

```bash
kubectl get roles
kubectl get rolebindings
```

- **Explanation**: Lists all roles and role bindings in the default namespace.

#### Describe a Role or RoleBinding

```bash
kubectl describe role <role-name>
kubectl describe rolebinding <rolebinding-name>
```

- **Explanation**: Displays detailed information about a specified role or role binding.

#### Create a RoleBinding

```bash
kubectl create rolebinding <rolebinding-name> --role=<role-name> --user=<user-name> -n <namespace>
```

- **Explanation**: Binds a role to a user within a specific namespace.

### 12. **Advanced Cluster Management**

#### Apply a YAML Configuration

```bash
kubectl apply -f <file.yaml>
```

- **Explanation**: Applies a resource configuration from a YAML file to the cluster.

#### Delete a Resource Using YAML

```bash
kubectl delete -f <file.yaml>
```

- **Explanation**: Deletes a resource defined in the specified YAML file.

#### Rollout Restart of a Deployment

```bash
kubectl rollout restart deployment <deployment-name>
```

- **Explanation**: Restarts a deployment to trigger a new rollout.

### 13. **Debugging and Troubleshooting**

#### Debug a Pod

```bash
kubectl debug -it <pod-name> --image=<debug-image>
```

- **Explanation**: Starts a temporary debugging container to inspect a pod.

#### Get Events in a Namespace

```bash
kubectl get events -n <namespace>
```

- **Explanation**: Lists events in a specific namespace, useful for troubleshooting.

#### Check Resource Utilization

```bash
kubectl top nodes
kubectl top pods
```

- **Explanation**: Displays resource usage (CPU, memory) for nodes or pods in the cluster.
