# 02 - S3 Cross-Region Replication

## Overview:
In this project, we will implement S3 Cross-Region Replication (CRR) between two Amazon S3 buckets located in different regions. The project ensures that objects uploaded to the source bucket are automatically replicated to a destination bucket in another region. This is useful for disaster recovery, compliance, and improving access to data for global users.

**Technologies used:**
- **AWS S3**: Object storage service used to store and replicate data.
- **IAM**: AWS Identity and Access Management for setting up necessary permissions.
- **AWS Management Console**: Interface to manage resources and configure replication.

**Key objectives:**
- Set up a source and destination S3 bucket.
- Enable versioning on both buckets.
- Configure replication rules for automatic data replication.
- Verify successful replication of objects between regions.

## Real-Life Use Case:
S3 Cross-Region Replication is frequently used by organizations for disaster recovery and data redundancy across regions. For example, an e-commerce platform storing user-uploaded files (like images or documents) can replicate these files to another region to ensure high availability and fault tolerance in case the primary region experiences downtime.

## Why and What: Tools and Their Functionality?

1. **S3 (Simple Storage Service)**: S3 is used as the main storage mechanism. CRR is enabled to automatically replicate data between buckets in different regions, ensuring data redundancy, compliance with regional data laws, and disaster recovery.
   
2. **IAM (Identity and Access Management)**: IAM roles and policies ensure secure access and allow S3 to replicate data from one bucket to another.

3. **Versioning**: Both the source and destination buckets must have versioning enabled. This ensures that even if an object is updated, previous versions can be preserved.

4. **Replication Rules**: AWS S3 replication rules define the conditions under which replication occurs, such as which objects are replicated and the destination bucket.

## Setup Instructions

### **Step 1: Create Source and Destination Buckets**

1. **Sub-step 1**: In the AWS Management Console, navigate to the **S3** service.
    - Create a bucket in the **ap-south-1** region (this will be the source bucket). Enable versioning during bucket creation.
    - Create another bucket in a region close to **ap-south-1**, such as **ap-southeast-1**. This will be the destination bucket. Make sure to enable versioning during bucket creation.
    - **Explanation**: Versioning is mandatory for replication because it tracks object changes and ensures both the source and destination buckets store all versions of objects.

2. **Sub-step 2**: Ensure that both buckets are using the **S3 Standard** storage class (which is free tier eligible).

### **Step 2: Configure IAM Role for Replication**

1. **Sub-step 1**: Go to the **IAM** console and create a new role.
    - Select **S3** as the trusted service.
    - Attach a policy that grants the source bucket permissions to replicate objects to the destination bucket.
    - **Explanation**: The role allows S3 to replicate data between the two buckets. The policy must include permissions like `s3:ReplicateObject` and `s3:GetObjectVersion`.

2. **Sub-step 2**: Attach the following policy to the IAM role:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObjectVersionForReplication",
        "s3:GetObjectVersionAcl",
        "s3:GetObjectVersionTagging"
      ],
      "Resource": "arn:aws:s3:::source-bucket/*"
    },
    {
      "Effect": "Allow",
      "Action": "s3:ReplicateObject",
      "Resource": "arn:aws:s3:::destination-bucket/*"
    }
  ]
}
```
Replace `source-bucket` and `destination-bucket` with your actual bucket names.

### **Step 3: Configure S3 Replication**

1. **Sub-step 1**: In the S3 console, go to the **source bucket** and select the **Management** tab. 
    - Click on **Create replication rule** and name the rule appropriately.
    - Set the **destination bucket** as the bucket you created in **ap-southeast-1**.
    - **Explanation**: The rule defines which objects will be replicated. You can choose to replicate all objects or a subset of objects based on prefixes or tags.

2. **Sub-step 2**: Select the IAM role you created earlier for replication permissions.
    - **Explanation**: This ensures that S3 can replicate data based on the permissions defined in the role.

### **Step 4: Test Cross-Region Replication**

1. **Sub-step 1**: Upload a few files to the source bucket.
    - **Explanation**: This is to ensure that the replication process is working as expected.

2. **Sub-step 2**: Verify that the objects appear in the destination bucket in **ap-southeast-1**. It may take a few minutes for the replication to occur.

---

## Testing and Validation

1. Upload an object to the source bucket and check if it replicates to the destination bucket. This can be verified via the AWS Management Console by checking the **Objects** tab in both buckets.
2. Check the version history in the destination bucket to confirm that all object versions from the source bucket are replicated.
3. Use the AWS CLI to list objects in the destination bucket:
   ```bash
   aws s3 ls s3://destination-bucket --region ap-southeast-1
   ```

---

## Clean Resources:

1. Delete the replication rule from the source bucket.
2. Disable versioning on both buckets to stop versioning costs.
3. Delete the source and destination buckets.
4. Delete the IAM role and attached policy. 

---

## Checklist:

- [ ] Create source and destination buckets with versioning enabled.
- [ ] Set up an IAM role for replication permissions.
- [ ] Configure S3 replication rules.
- [ ] Test the replication by uploading objects.
- [ ] Clean up all AWS resources to avoid unnecessary charges.

---

## Scripts (Optional):

You can use the following AWS CLI commands to automate bucket creation and replication rule configuration:
```bash
# Create source and destination buckets
aws s3api create-bucket --bucket my-source-bucket --region ap-south-1
aws s3api create-bucket --bucket my-destination-bucket --region ap-southeast-1

# Enable versioning on both buckets
aws s3api put-bucket-versioning --bucket my-source-bucket --versioning-configuration Status=Enabled
aws s3api put-bucket-versioning --bucket my-destination-bucket --versioning-configuration Status=Enabled
```