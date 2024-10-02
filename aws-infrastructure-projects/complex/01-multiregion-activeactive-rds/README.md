**Multi-Region Active-Active RDS Deployment**

## Overview:
This project focuses on deploying a highly available, fault-tolerant multi-region Active-Active RDS (Relational Database Service) setup using AWS. The objective is to demonstrate how to architect and configure RDS in multiple AWS regions to ensure database availability even during regional failures. We will use AWS RDS, Route 53, and IAM to manage the database and ensure proper access controls, leveraging Amazon Aurora Global Database for efficient cross-region replication.

### Technologies and Tools:
- **Amazon RDS (Aurora Global Database)**: Provides a highly available, scalable, and multi-region architecture for relational databases.
- **Amazon Route 53**: Ensures failover capability by routing traffic between regions.
- **IAM (Identity and Access Management)**: Configures roles and policies for security and access management.
  
### Main Objectives:
- Create an active-active multi-region RDS setup using Amazon Aurora Global Database.
- Configure Route 53 for automated regional failover.
- Validate the setup by connecting and querying the database from different regions.

## Real-Life Use Case:
In industries like e-commerce, finance, and SaaS applications, where downtime can directly impact revenue and customer satisfaction, having a globally distributed, active-active database system is crucial. By using Aurora Global Database, companies can ensure low-latency reads and quick recovery from regional failures, achieving high availability and disaster recovery. This project simulates a real-life enterprise scenario where databases need to be always accessible, regardless of regional outages.

## Why and What: Tools and Their Functionality?

### Amazon RDS (Aurora Global Database):
- **Why**: Provides a globally distributed relational database with automatic failover and high availability. It reduces downtime, supports disaster recovery, and offers low-latency access across regions.
- **What**: Aurora Global Database allows a single database to span multiple AWS regions, using a primary region for writes and allowing reads from secondary regions.

### Amazon Route 53:
- **Why**: Needed to handle traffic routing and failover. It automatically redirects database traffic to the healthiest region during an outage.
- **What**: Route 53 is a scalable domain name system (DNS) web service that helps manage traffic routing between AWS resources.

### IAM (Identity and Access Management):
- **Why**: Ensures secure access to the RDS instances and Route 53 configurations by defining specific permissions for users and services.
- **What**: IAM allows the creation of roles and policies to manage who can access the RDS instances and how they can interact with Route 53.

## Setup Instructions:

### **Step 1: Set Up IAM Roles for RDS and Route 53**

1. **Create IAM Roles for RDS and Route 53**:  
   - In the IAM console, create a role for RDS that will allow RDS to communicate with Route 53. Attach the necessary policies such as `AmazonRDSFullAccess` and `AmazonRoute53FullAccess`.
   - **Why**: IAM roles allow secure, managed access between services without needing to provide explicit credentials.
   - **What**: These policies enable RDS to handle failover routing automatically.

2. **Create a Policy for Aurora Global Database**:  
   - Create a custom IAM policy that grants necessary permissions to manage Aurora Global Database replication.
   - **Why**: This custom policy ensures Aurora can manage cross-region replication efficiently.
   - **What**: This ensures that Aurora Global Database operates across regions without additional permissions issues.

---

### **Step 2: Deploy Aurora Global Database**

1. **Create an Aurora Cluster in the Primary Region**:  
   - Use the AWS Management Console to create an Aurora DB cluster in your primary region (e.g., `ap-southeast-1`). Select `Aurora Global Database` in the RDS options.
   - **Why**: Aurora Global Database enables replication across regions with a low-latency configuration.
   - **What**: This will serve as your main write cluster for the multi-region setup.

2. **Add a Secondary Region**:  
   - Once the Aurora DB in the primary region is deployed, select the cluster and click "Add Region." Choose a secondary region (e.g., `ap-southeast-2`) to add as a read replica.
   - **Why**: Adding a secondary region ensures cross-region replication and failover capabilities.
   - **What**: The secondary region will serve as a backup in case the primary region becomes unavailable.

3. **Enable Multi-AZ for RDS in Both Regions**:  
   - Ensure both the primary and secondary regions have Multi-AZ enabled for high availability within each region.
   - **Why**: Multi-AZ ensures local high availability in each region.
   - **What**: This reduces downtime during regional failures.

---

### **Step 3: Configure Route 53 for Traffic Routing**

1. **Create Route 53 Health Checks for RDS Instances**:  
   - In the Route 53 console, create health checks for the RDS instances in both regions. Ensure the health check pings the RDS endpoints for availability.
   - **Why**: Health checks allow Route 53 to monitor the availability of each RDS region and route traffic based on the results.
   - **What**: This automates traffic failover between regions based on RDS health.

2. **Create a DNS Failover Routing Policy**:  
   - Configure Route 53 with failover routing policies for both RDS endpoints. Use the primary region as the default and the secondary region as the failover.
   - **Why**: Failover routing policies ensure automatic traffic switching to a healthy region.
   - **What**: This ensures that during a regional outage, traffic is redirected seamlessly.

---

## Testing and Validation:

1. **Validate Cross-Region Replication**:  
   - Connect to the RDS instances in both regions and verify that data written to the primary region appears in the secondary region.
   - **How**: Use an application (e.g., MySQL Workbench) to connect to both instances and run test queries.

2. **Simulate Failover**:  
   - Simulate a failure in the primary region by manually disabling the RDS instance in the primary region. Use Route 53 to observe the failover behavior.
   - **How**: Route 53 should automatically redirect traffic to the secondary region. Verify by connecting to the secondary region RDS endpoint.

---

## Clean Resources:
1. **Delete the Aurora Clusters**:  
   - Terminate both the primary and secondary Aurora clusters.
2. **Delete Route 53 Configurations**:  
   - Remove the DNS records and health checks created for failover.
3. **Delete IAM Roles and Policies**:  
   - Remove all custom roles and policies created for this project.

---

## Checklist:
- [ ] IAM roles and policies created for RDS and Route 53.
- [ ] Aurora Global Database deployed in both regions.
- [ ] Route 53 health checks and failover routing configured.
- [ ] Validation of cross-region replication.
- [ ] Simulated failover and Route 53 testing.
- [ ] All resources cleaned up to avoid cost.

---

## Scripts (Optional):
- create-aurora-global.sh:
- test-failover.sh

