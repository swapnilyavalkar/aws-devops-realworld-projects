#!/bin/bash

# Variables
PRIMARY_REGION="ap-southeast-1"
SECONDARY_REGION="ap-southeast-2"
DB_CLUSTER_IDENTIFIER="aurora-global-cluster"
INSTANCE_CLASS="db.t3.micro"  # Low-cost instance type
DB_ENGINE="aurora-mysql"
DB_NAME="mydb"
MASTER_USERNAME="admin"
MASTER_PASSWORD="yourpassword"

# Step 1: Create Primary Aurora DB Cluster
echo "Creating the Aurora DB Cluster in the primary region ($PRIMARY_REGION)..."
aws rds create-db-cluster \
  --db-cluster-identifier $DB_CLUSTER_IDENTIFIER \
  --engine $DB_ENGINE \
  --engine-version "5.7.mysql_aurora.2.07.1" \
  --master-username $MASTER_USERNAME \
  --master-user-password $MASTER_PASSWORD \
  --db-subnet-group-name default \
  --vpc-security-group-ids sg-xxxxxxxx \
  --region $PRIMARY_REGION

# Step 2: Create DB Instance in Primary Region (Low-Cost Instance)
echo "Creating DB instance in primary region..."
aws rds create-db-instance \
  --db-instance-identifier ${DB_CLUSTER_IDENTIFIER}-instance \
  --db-cluster-identifier $DB_CLUSTER_IDENTIFIER \
  --db-instance-class $INSTANCE_CLASS \
  --engine $DB_ENGINE \
  --region $PRIMARY_REGION

# Step 3: Add Secondary Region to Aurora Global Cluster
echo "Adding the secondary region ($SECONDARY_REGION)..."
aws rds create-global-cluster \
  --global-cluster-identifier $DB_CLUSTER_IDENTIFIER \
  --source-db-cluster-identifier arn:aws:rds:$PRIMARY_REGION:your-account-id:cluster:$DB_CLUSTER_IDENTIFIER \
  --region $SECONDARY_REGION

# Step 4: Create DB Instance in Secondary Region (Low-Cost Instance)
echo "Creating DB instance in secondary region..."
aws rds create-db-instance \
  --db-instance-identifier ${DB_CLUSTER_IDENTIFIER}-instance-secondary \
  --db-cluster-identifier $DB_CLUSTER_IDENTIFIER \
  --db-instance-class $INSTANCE_CLASS \
  --engine $DB_ENGINE \
  --region $SECONDARY_REGION

echo "Aurora Global Database setup with low-cost resources is complete."