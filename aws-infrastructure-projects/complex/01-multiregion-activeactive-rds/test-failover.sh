#!/bin/bash

# Variables
PRIMARY_INSTANCE_IDENTIFIER="aurora-global-cluster-instance"
SECONDARY_REGION="ap-southeast-2"
DNS_NAME="aurora-primary.myglobaldb.com"
ROUTE53_HEALTHCHECK_ID="your-health-check-id"

# Step 1: Stop the Primary Aurora Instance
echo "Stopping the primary Aurora DB instance..."
aws rds stop-db-instance \
  --db-instance-identifier $PRIMARY_INSTANCE_IDENTIFIER \
  --region ap-southeast-1

# Step 2: Wait for Route 53 Failover (5 minutes wait)
echo "Waiting for Route 53 failover..."
sleep 300

# Step 3: Check DNS record status in Route 53
echo "Checking the DNS status..."
DNS_RESULT=$(nslookup $DNS_NAME)

# Step 4: Check Route 53 Health Check status
HEALTHCHECK_STATUS=$(aws route53 get-health-check-status \
  --health-check-id $ROUTE53_HEALTHCHECK_ID)

echo "Failover test complete."
echo "DNS Result: $DNS_RESULT"
echo "Route 53 Health Check Status: $HEALTHCHECK_STATUS"