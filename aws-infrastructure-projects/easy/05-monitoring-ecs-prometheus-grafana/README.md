# 05 - Monitoring ECS with Prometheus and Grafana

## Overview:
In this project, we will implement monitoring for Amazon ECS (Elastic Container Service) using **Prometheus** and **Grafana**. Prometheus is a popular open-source monitoring solution that scrapes metrics from services, while Grafana is used for visualizing and analyzing those metrics through customizable dashboards. The project will involve setting up Prometheus to scrape ECS metrics and configuring Grafana to display those metrics, giving real-time insights into ECS cluster health and performance.

**Technologies used:**
- **Amazon ECS**: Managed container orchestration service.
- **Prometheus**: Monitoring system to collect and store metrics.
- **Grafana**: Visualization tool to build and manage dashboards.
- **AWS CloudWatch**: Optional, for forwarding ECS metrics to Prometheus using CloudWatch.

**Key objectives:**
- Set up ECS to run containerized services.
- Deploy Prometheus to scrape ECS metrics.
- Set up Grafana to visualize and monitor ECS metrics.
- Ensure ECS services are monitored in real-time for performance, resource usage, and system health.

## Real-Life Use Case:
This monitoring setup is commonly used in production environments where multiple ECS clusters are deployed to manage microservices. For example, an online retail platform may run different containerized services (like payment processing, inventory management, and customer support) on ECS. Prometheus and Grafana will help operations teams monitor these services, ensuring that they are running smoothly and are not consuming too many resources, while also alerting them to any potential issues.

## Why and What: Tools and Their Functionality?

1. **Amazon ECS**: ECS is used to orchestrate containerized applications. Monitoring ECS helps ensure the services running on the cluster are performant, using the right amount of resources, and have no service disruptions.

2. **Prometheus**: Prometheus is used to scrape and store metrics from ECS and other services. It acts as a central monitoring tool to collect metrics from multiple sources and provide a time-series data store.

3. **Grafana**: Grafana will visualize the metrics collected by Prometheus, allowing you to build dashboards for ECS metrics. Grafana also supports alerting, helping you proactively manage your ECS clusters.

4. **CloudWatch (Optional)**: If needed, CloudWatch can forward ECS metrics to Prometheus, enabling more integration between AWS’s native monitoring services and open-source tools.

## Setup Instructions

### **Step 1: Set Up ECS Cluster**

1. **Sub-step 1**: Navigate to the **ECS** service in the AWS Management Console and create a new ECS cluster.
    - Choose the **EC2 launch type** (or **Fargate** if you prefer serverless containers).
    - Select **t2.micro** instances (or **free-tier** resources) if you're using EC2 for cost management.
    - **Explanation**: ECS will host the containerized services we intend to monitor. Choosing `t2.micro` helps avoid unnecessary costs.

2. **Sub-step 2**: Create a simple ECS service that runs a container (e.g., an NGINX container).
    - Create a **task definition** and define the container image (e.g., `nginx`).
    - Specify the port mappings (e.g., port 80) and the desired number of tasks.
    - **Explanation**: This service will represent a typical workload you want to monitor in a real-world scenario.

### **Step 2: Deploy Prometheus on ECS**

1. **Sub-step 1**: Create a new task definition for Prometheus.
    - In the ECS Management Console, create a **task definition** for running Prometheus.
    - Use the official Prometheus image from Docker Hub (`prom/prometheus`).
    - Set up port mapping for Prometheus (e.g., port 9090).
    - **Explanation**: Prometheus will scrape metrics from ECS services, so running it on the same ECS cluster simplifies communication between Prometheus and the services.

2. **Sub-step 2**: Configure Prometheus to scrape ECS metrics.
    - Create a configuration file (`prometheus.yml`) for Prometheus that defines scrape targets.
    - For scraping ECS, you may need to enable **CloudWatch Container Insights** for ECS and configure a CloudWatch-to-Prometheus exporter.

    Example `prometheus.yml`:
    ```yaml
    global:
      scrape_interval: 15s

    scrape_configs:
      - job_name: 'ecs-metrics'
        metrics_path: /metrics
        static_configs:
          - targets: ['<ECS-service-IP>:<metrics-port>']
    ```
    - **Explanation**: The scrape configuration defines the ECS service as a target. Prometheus will collect metrics from the specified IP and port.

3. **Sub-step 3**: Deploy the Prometheus service on ECS using the task definition created earlier.
    - Ensure that Prometheus is running and accessible via port 9090.
    - **Explanation**: This ensures that Prometheus is up and running, collecting metrics from your ECS cluster.

### **Step 3: Deploy Grafana on ECS**

1. **Sub-step 1**: Create a task definition for Grafana.
    - Use the official Grafana Docker image (`grafana/grafana`).
    - Set up port mapping (e.g., port 3000) for Grafana access.
    - **Explanation**: Grafana will be deployed as a service in the same ECS cluster, making it easy to visualize Prometheus metrics.

2. **Sub-step 2**: Deploy the Grafana task on ECS.
    - Define the environment variables for Grafana (e.g., `GF_SECURITY_ADMIN_PASSWORD`) to configure the admin user.
    - Deploy the Grafana service in the ECS cluster and ensure that it's accessible via the correct port (default is 3000).
    - **Explanation**: Grafana will visualize metrics, so ensuring it's accessible via the web is critical for monitoring.

### **Step 4: Configure Grafana to Use Prometheus as a Data Source**

1. **Sub-step 1**: Access Grafana by navigating to the IP address of your ECS service on port 3000.
    - Log in using the admin credentials defined earlier.

2. **Sub-step 2**: Add Prometheus as a data source.
    - In Grafana, go to **Configuration** > **Data Sources**.
    - Add a new data source and choose **Prometheus**.
    - Provide the Prometheus endpoint (e.g., `http://<prometheus-service-IP>:9090`).
    - **Explanation**: This step links Grafana to Prometheus, enabling Grafana to visualize the metrics scraped by Prometheus.

3. **Sub-step 3**: Import ECS monitoring dashboards.
    - In Grafana, go to **Dashboard** > **Import** and use the Prometheus ECS monitoring dashboard template.
    - **Explanation**: Prebuilt Grafana dashboards simplify the process of visualizing ECS metrics, providing a quick and efficient way to monitor your services.

---

## Testing and Validation

1. **Test Prometheus Scraping**:
   - Go to the Prometheus web UI (via port 9090) and check the status of the ECS scrape targets.
   - You can use the `targets` endpoint (`http://<prometheus-IP>:9090/targets`) to verify if ECS services are being scraped successfully.
   
2. **Test Grafana Visualization**:
   - Open Grafana and check the dashboards for ECS metrics.
   - You should see metrics like CPU usage, memory utilization, and task status for the ECS cluster and services.
   
3. **Validate Alerts** (Optional):
   - Set up Grafana alerts to notify you when certain ECS metrics (like high CPU or memory usage) exceed a threshold.
   - Use the Alerting section in Grafana to configure these thresholds and notifications.

---

## Clean Resources:

1. **Delete ECS Services**: 
   - Go to the **ECS console** and delete the services (Prometheus, Grafana, and any other services running on ECS).
   - **Explanation**: Deleting the services ensures that no additional ECS resources are running, avoiding unnecessary charges.

2. **Delete Task Definitions**: 
   - In the **ECS console**, deregister and delete the task definitions created for Prometheus and Grafana.
   - **Explanation**: Removing task definitions prevents accidental re-launch of the services.

3. **Delete Cluster**: 
   - In the **ECS console**, delete the ECS cluster.
   - **Explanation**: Deleting the ECS cluster removes all underlying resources such as EC2 instances or Fargate tasks.

---

## Checklist:

- [ ] Create ECS cluster and service for Prometheus and Grafana.
- [ ] Deploy Prometheus to scrape ECS metrics.
- [ ] Set up Grafana to visualize ECS metrics.
- [ ] Test ECS monitoring using Prometheus and Grafana dashboards.
- [ ] Clean up ECS services, task definitions, and clusters.

---

## Scripts (Optional):

To automate the deployment of Prometheus and Grafana on ECS, use the following ECS CLI commands:
```bash
# Create a new ECS cluster
ecs-cli up --cluster-config MyClusterConfig

# Deploy Prometheus service
ecs-cli compose --file prometheus-compose.yml service up

# Deploy Grafana service
ecs-cli compose --file grafana-compose.yml service up
```