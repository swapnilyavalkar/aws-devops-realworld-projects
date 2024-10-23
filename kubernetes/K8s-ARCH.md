# K8s Architecture

## 1. **ETCD (Distributed Key-Value Store)**

- **Details**:
  - etcd is a distributed, reliable key-value store used as Kubernetes’ primary data store.
- **Work**:
  - Stores all cluster data, including configuration data, resource states, and metadata.
  - Serves as the “single source of truth” for the entire cluster state.
- **Features**:
  - Highly available and consistent.
  - Supports leader election and automatic failover.
  - Provides key-value data storage with watch and transaction capabilities.
- **Why it is used**:
  - etcd ensures consistency and durability of cluster data.
  - It is crucial for leader election, service discovery, and distributed coordination within Kubernetes.
- **Use Case Example**: When a new pod is scheduled, the configuration data is fetched from etcd to maintain consistency.

## 2. **API Server (kube-apiserver)**

- **Details**:
  - Acts as the front-end and communication hub of the Kubernetes control plane.
- **Work**:
  - Exposes the Kubernetes API, acting as the central point for interacting with the cluster.
  - Processes RESTful requests (CRUD operations) to manage resources and serves as a gateway to the etcd database.
- **Features**:
  - Authentication and authorization (via tokens and certificates).
  - Admission control to validate API requests.
  - Scaling and load balancing of API requests.
- **Why it is used**:
  - It serves as the primary interface for users and other components to interact with the cluster.
  - Enables developers and tools like `kubectl` to manage clusters programmatically.
- **Use Case Example**: When you run `kubectl apply -f <file.yaml>`, the API server processes this request and makes changes in etcd accordingly.

## 3. **Controller Manager (kube-controller-manager)**

The **Kubernetes Controller Manager (kube-controller-manager)** is a central component of the Kubernetes control plane that runs a set of controller processes responsible for monitoring and maintaining the desired state of various cluster resources. It operates through different controllers, each focused on managing specific resources or aspects of the cluster.

- **Details**:
  - A daemon that runs various controllers to manage cluster states automatically.
- **Work**:
  - Monitors the desired state in etcd and continuously reconciles the actual state to match it.
  - Includes various controllers: Node Controller, Replication Controller, Endpoints Controller, Service Account Controller, etc.
- **Features**:
  - Automatic pod rescheduling if a node fails.
  - Manages replication to ensure the desired number of pod replicas are running.
  - Handles endpoints and service account management.
- **Why it is used**:
  - It ensures that the cluster state is always consistent and self-healing by managing resource failures and rescheduling.
- **Use Case Example**: If a pod goes down, the Replication Controller ensures a new pod is spun up to maintain the desired number of replicas.

### **KUBE CONTROLLER MANAGER COMPONENTS**

#### 1. **Node Controller**

- **Details**:
  - Responsible for monitoring and managing the state of nodes in the cluster.
- **Work**:
  - It checks the status of nodes and detects node failures.
  - Monitors node health by receiving heartbeat signals from kubelets.
  - If a node stops sending heartbeats for a certain duration, it marks the node as “Not Ready” and schedules rescheduling of pods.
- **Features**:
  - Detects node failures quickly.
  - Handles node deletion and resource cleanup.
  - Supports taints and tolerations to manage pod placement on nodes.
- **Why it is used**:
  - Ensures that pods are rescheduled to other nodes when a node becomes unavailable, maintaining cluster reliability.
- **Use Case Example**: If a node fails and becomes unresponsive, the Node Controller marks the node as “Not Ready” and triggers rescheduling of pods to healthy nodes.

#### 2. **Replication Controller**

- **Details**:
  - Ensures that a specified number of pod replicas are running at any given time.
- **Work**:
  - It watches the etcd store for changes and creates, updates, or deletes pods to match the desired number of replicas.
  - It continuously ensures that the actual number of running pods matches the desired replicas.
- **Features**:
  - Manages pod scaling by creating or deleting pods.
  - Ensures high availability by replacing failed pods.
  - Can be replaced by ReplicaSets (an improved version) in newer versions of Kubernetes.
- **Why it is used**:
  - Ensures that the application is highly available by maintaining a set number of pod replicas.
- **Use Case Example**: If a pod is terminated unexpectedly, the Replication Controller creates a new pod to maintain the desired number of replicas.

#### 3. **Endpoints Controller**

- **Details**:
  - Manages the association between services and pods by maintaining endpoint objects.
- **Work**:
  - It watches for new services and pods and creates/update endpoint objects, which contain the IP addresses and ports of the pods backing the service.
  - Ensures that the list of endpoints for each service is accurate and up-to-date.
- **Features**:
  - Supports service discovery by creating endpoints for service-pod mapping.
  - Updates endpoints automatically as pods are added or removed.
- **Why it is used**:
  - Ensures that service traffic is routed to the correct set of pods, enabling accurate internal communication.
- **Use Case Example**: If new pods are created for a service, the Endpoints Controller updates the service’s endpoint list to include the new pod IPs, ensuring accurate routing.

#### 4. **Service Account Controller**

- **Details**:
  - Responsible for managing service accounts and tokens.
- **Work**:
  - It creates default service accounts in new namespaces.
  - Generates and manages service account tokens to allow pods to authenticate with the API server.
- **Features**:
  - Automatically creates service accounts for namespaces.
  - Manages secrets containing authentication tokens for service accounts.
  - Facilitates secure communication between pods and the API server.
- **Why it is used**:
  - Ensures that each pod has the necessary credentials to interact with the API server securely.
- **Use Case Example**: When a new namespace is created, the Service Account Controller automatically creates a default service account for it, enabling secure pod communication within the namespace.

#### 5. **Job Controller**

- **Details**:
  - Manages Job resources that handle batch tasks.
- **Work**:
  - Monitors the status of Job resources and ensures that the specified number of job pods run to completion.
  - Restarts failed job pods until the completion condition is met.
- **Features**:
  - Supports parallel job execution.
  - Ensures successful completion of batch tasks.
  - Allows retry policies for failed jobs.
- **Why it is used**:
  - Ensures that batch tasks complete successfully, even if some pods fail during execution.
- **Use Case Example**: If a job requires three pods to process data, the Job Controller ensures that all three pods run to completion and handles retries if any of them fail.

#### 6. **CronJob Controller**

- **Details**:
  - Manages CronJob resources for running jobs on a scheduled basis.
- **Work**:
  - Creates jobs at scheduled times based on the CronJob schedule.
  - Monitors and ensures that jobs run as per the defined schedule.
- **Features**:
  - Supports scheduling with cron-like syntax.
  - Manages job history and cleanup of old jobs.
- **Why it is used**:
  - Enables automation of recurring tasks, like backups or maintenance, on a defined schedule.
- **Use Case Example**: A CronJob is scheduled to run a backup task every day at midnight, and the CronJob Controller ensures that the job is triggered on time.

#### 7. **DaemonSet Controller**

- **Details**:
  - Manages DaemonSets, ensuring that a specific pod runs on all or selected nodes.
- **Work**:
  - Monitors DaemonSet resources and schedules the necessary pods on each eligible node.
  - Manages the lifecycle of DaemonSet pods during node addition, deletion, or update.
- **Features**:
  - Ensures system-level services like logging, monitoring, or networking are present on all nodes.
  - Supports rolling updates and deletion of DaemonSet pods.
- **Why it is used**:
  - Ensures that specific system-level workloads, such as logging agents, run consistently on all or selected nodes.
- **Use Case Example**: If a new node is added to the cluster, the DaemonSet Controller ensures that the logging agent pod is scheduled on the new node.

#### 8. **StatefulSet Controller**

- **Details**:
  - Manages StatefulSets, which are designed for stateful applications that require stable network IDs, persistent storage, and ordered deployment.
- **Work**:
  - Manages the creation, scaling, and deletion of StatefulSet pods in a specific order.
  - Ensures stable network IDs and persistent storage for stateful applications like databases.
- **Features**:
  - Provides ordered, graceful scaling and deletion of pods.
  - Supports volume claim templates for persistent storage.
- **Why it is used**:
  - Ensures the reliable operation of stateful applications that require predictable startup and termination sequences.
- **Use Case Example**: When scaling up a StatefulSet for a database, the StatefulSet Controller ensures that new pods are added in a specified order.

#### 9. **ReplicaSet Controller**

- **Details**:
  - Manages ReplicaSets, which are an improved version of Replication Controllers.
- **Work**:
  - Monitors ReplicaSet resources and maintains the desired number of replicas.
  - Ensures new pods are created or deleted to match the desired state.
- **Features**:
  - Supports label selectors for flexible pod selection.
  - Manages scaling up or down of replicas.
- **Why it is used**:
  - Provides a more flexible and efficient way to manage pod replicas than the older Replication Controller.
- **Use Case Example**: If a new ReplicaSet is created with three replicas, the ReplicaSet Controller ensures that exactly three pods are running at all times.

#### 10. **Horizontal Pod Autoscaler (HPA) Controller**

- **Details**:
  - Manages the Horizontal Pod Autoscaler, which automatically scales pods based on CPU/memory utilization or custom metrics.
- **Work**:
  - Monitors the metrics (CPU, memory, or custom metrics) and adjusts the number of pod replicas accordingly.
- **Features**:
  - Supports auto-scaling based on resource utilization.
  - Works with metrics collected from the Metrics Server.
- **Why it is used**:
  - Ensures that applications can scale up or down automatically to handle varying workloads, improving resource utilization.
- **Use Case Example**: If CPU usage exceeds 80% for a deployment, the HPA Controller scales the deployment up by adding more replicas.

#### 11. **Garbage Collector Controller**

- **Details**:
  - Responsible for cleaning up resources that are no longer needed.
- **Work**:
  - Automatically deletes orphaned objects, such as pods left behind when their owning resources are deleted.
- **Features**:
  - Identifies and removes resources based on owner references.
- **Why it is used**:
  - Maintains a clean cluster state by ensuring that obsolete resources are removed automatically.
- **Use Case Example**: If a ReplicaSet is deleted, the Garbage Collector ensures that its associated pods are also deleted.

#### 12. **TTL Controller for Finished Resources**

- **Details**:
  - Manages resources with a specified time-to-live (TTL) after completion, such as Jobs.
- **Work**:
  - Deletes finished jobs and pods after a specified TTL.
- **Features**:
  - Configurable TTL for automatic cleanup of finished resources.
- **Why it is used**
  - Reduces cluster clutter by automatically removing completed jobs and pods after a set duration.
- **Use Case Example**: If a job completes its execution, the TTL Controller deletes it after the defined TTL (e.g., 1 hour).
Kubernetes Controller Manager

---

## 4. **Scheduler (kube-scheduler)**

- **Details**:
  - A component that determines which node an unscheduled pod will run on.
- **Work**:
  - Monitors newly created pods that do not have an assigned node and selects an appropriate node for them based on resource requirements and constraints.
  - Factors in resource availability (CPU, memory), node affinity, taints, tolerations, and other criteria.
- **Features**:
  - Extensible scheduling policies.
  - Efficient resource utilization and balanced workload distribution.
  - Prioritizes scheduling based on predefined policies.
- **Why it is used**:
  - It ensures optimal pod placement, leading to efficient resource usage, reduced contention, and high availability.
- **Use Case Example**: When a deployment requests three replicas, the scheduler assigns each new pod to a node that meets resource requirements and scheduling policies.

## 5. **Kubelet**

- **Details**:
  - An agent running on each node that ensures the containers are running as expected.
- **Work**:
  - Receives pod specifications from the API server and manages the lifecycle of pods.
  - Interacts with container runtimes (e.g., Docker, containerd) to start, stop, and monitor container states.
- **Features**:
  - Monitors pod status, health checks, and resource utilization.
  - Integrates with container runtime interfaces (CRIs).
  - Supports liveness and readiness probes to determine container health.
- **Why it is used**:
  - It manages container operations on individual nodes and keeps the API server updated with the node and pod statuses.
- **Use Case Example**: If a pod crashes on a node, the kubelet detects this failure and attempts to restart it based on its specifications.

## 6. **Kube-Proxy**

- **Details**:
  - A network proxy that runs on each node to manage Kubernetes networking.
- **Work**:
  - Maintains network rules for pod-to-pod communication within the cluster and external communication.
  - Implements service routing, allowing communication to a stable service IP that routes traffic to corresponding pods.
- **Features**:
  - Supports load balancing across pods.
  - Handles Network Address Translation (NAT) for incoming service requests.
  - Implements IP tables or IP Virtual Server (IPVS) rules for routing.
- **Why it is used**:
  - Provides seamless service discovery and load balancing, enabling internal and external traffic to reach the appropriate services.
- **Use Case Example**: When an external request reaches the cluster, kube-proxy ensures it is routed to the right pod based on the service definition.

## 7. **Container Runtime (e.g., Docker, containerd, CRI-O)**

- **Details**:
  - Software that is responsible for running containers in a pod.
- **Work**:
  - It pulls container images from container registries, creates containers, and manages their lifecycle.
- **Features**:
  - Supports various container image formats.
  - Integrates with Kubernetes through the Container Runtime Interface (CRI).
  - Provides isolation and resource management for containers.
- **Why it is used**:
  - Containers are the core of Kubernetes applications, and container runtimes are needed to manage container lifecycles and runtime operations.
- **Use Case Example**: When a pod definition specifies a container image, the runtime downloads it, creates the container, and starts it on the node.

## 8. **Add-ons (Optional but Important Components)**

### a. **CoreDNS**

- **Details**: DNS server that provides DNS-based service discovery within the cluster.
- **Work**: Automatically assigns DNS names to services and pods, enabling service discovery via DNS.
- **Features**:
  - Supports DNS resolution, service discovery, and load balancing.
- **Why it is used**: Simplifies service discovery by providing DNS-based routing.
- **Use Case Example**: A pod in the cluster can communicate with another service by using its DNS name.

### b. **Dashboard**

- **Details**: A web-based UI for managing and monitoring Kubernetes clusters.
- **Work**: Allows users to deploy applications, view logs, and monitor resource usage.
- **Features**:
  - Provides user-friendly access to cluster resources.
  - Supports creating, modifying, and deleting resources through a web interface.
- **Why it is used**: Provides an intuitive UI for cluster administration and visualization.
- **Use Case Example**: Admins use the dashboard to visualize cluster resource utilization and troubleshoot issues.

### c. **Metrics Server**

- **Details**: Aggregates and provides cluster-wide metrics for resource monitoring and auto-scaling.
- **Work**: Collects resource utilization metrics (CPU, memory) from nodes and pods.
- **Features**:
  - Provides metrics for Horizontal Pod Autoscaler (HPA).
- **Why it is used**: Enables metrics-based auto-scaling and monitoring.
- **Use Case Example**: HPA uses metrics collected by the metrics server to scale pods up or down based on CPU usage.

## 9. **Cluster Autoscaler**

- **Details**: A component that automatically adjusts the number of nodes in the cluster based on resource requirements.
- **Work**:
  - Adds nodes when there is a resource shortage and removes nodes when they are underutilized.
- **Features**:
  - Supports auto-scaling based on pod resource requirements.
  - Optimizes cost and resource efficiency.
- **Why it is used**: Ensures that the cluster can dynamically scale infrastructure based on workload needs.
- **Use Case Example**: During peak traffic, it automatically scales up the cluster by adding more nodes.

## 10. **Helm (Package Manager)**

- **Details**: Not a core component but widely used for deploying and managing Kubernetes applications.
- **Work**:
  - Helm uses charts (predefined templates) to deploy complex applications and manage their configurations.
- **Features**:
  - Simplifies deployment with reusable templates.
  - Supports rollbacks, upgrades, and dependency management.
- **Why it is used**: Reduces deployment complexity, especially for large, multi-resource applications.
- **Use Case Example**: Deploying an application with multiple services, config maps, and deployments using a single Helm chart.

## 11. **Ingress Controller**

- **Details**: Manages external access to services, typically via HTTP/HTTPS.
- **Work**:
  - Implements routing rules to direct external traffic to appropriate services within the cluster.
- **Features**:
  - Supports TLS termination, path-based routing, and virtual hosting
- **Why it is used**: Provides external access to services using a single entry point.
- **Use Case Example**: Allows external users to access a web application hosted on a Kubernetes cluster via a single URL.

## Summary of Kubernetes Architecture

- **Control Plane Components**: API Server, Controller Manager, Scheduler, etcd.
  - Manage cluster-wide decisions, workloads, and data persistence.
- **Node Components**: Kubelet, Kube-Proxy, Container Runtime.
  - Manage node-specific operations, pod lifecycles, and networking.
- **Add-ons & Optional Components**: CoreDNS, Metrics Server, Dashboard, Cluster Autoscaler, Helm, Ingress Controller.
  - Enhance functionality, monitoring, scalability, and application management.
