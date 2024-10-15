# 06 - Infrastructure as Code: CloudFormation

## Overview:
In this project, we will use **AWS CloudFormation** to define and manage infrastructure as code. CloudFormation allows you to describe your AWS resources in JSON or YAML templates, enabling automated and consistent provisioning of AWS services. This project involves creating a CloudFormation template that provisions a fully functional infrastructure, including EC2 instances, security groups, and S3 buckets, following the principles of Infrastructure as Code (IaC).

**Technologies used:**
- **AWS CloudFormation**: Service to define and manage AWS infrastructure in a declarative way.
- **IAM**: Provides permissions required to manage CloudFormation stacks.
- **EC2**: Virtual servers for compute capacity.
- **S3**: Object storage for storing templates or other assets.

**Key objectives:**
- Implement infrastructure as code using CloudFormation.
- Create a reusable CloudFormation template.
- Deploy an EC2 instance, S3 bucket, and security group using the template.
- Automate infrastructure provisioning with minimal manual intervention.

## Real-Life Use Case:
CloudFormation is widely used in organizations for automating infrastructure provisioning. For instance, a company launching multiple environments (like development, testing, production) can use CloudFormation templates to consistently deploy identical infrastructure across different AWS accounts and regions. This ensures that every environment follows the same configuration, reducing errors and manual overhead.

## Why and What: Tools and Their Functionality?

1. **CloudFormation**: CloudFormation enables you to define your entire AWS infrastructure as code. Using templates ensures repeatability and consistency, reducing human error and making the infrastructure deployment process more efficient.
   
2. **IAM**: IAM roles are used to define permissions for CloudFormation to create, update, and delete resources. A properly configured role ensures that CloudFormation can operate securely without over-provisioned permissions.

3. **EC2**: As a compute resource, EC2 instances will be launched via CloudFormation as part of the infrastructure.

4. **S3**: S3 buckets are used to store files, assets, and CloudFormation templates. In this project, an S3 bucket will be created to store data related to the infrastructure.

## Setup Instructions

### **Step 1: Create CloudFormation Template**

1. **Sub-step 1**: Open a text editor (like Visual Studio Code) and create a YAML template for CloudFormation. The template will describe all resources like EC2, S3, and security groups.
   
   Example YAML template:
   ```yaml
   AWSTemplateFormatVersion: '2010-09-09'
   Resources:
     MyEC2Instance:
       Type: 'AWS::EC2::Instance'
       Properties:
         InstanceType: t2.micro
         KeyName: my-key-pair
         ImageId: ami-0c55b159cbfafe1f0  # Replace with the latest Amazon Linux 2 AMI ID for your region
         SecurityGroups:
           - Ref: MySecurityGroup

     MySecurityGroup:
       Type: 'AWS::EC2::SecurityGroup'
       Properties:
         GroupDescription: Enable SSH access
         SecurityGroupIngress:
           - IpProtocol: tcp
             FromPort: 22
             ToPort: 22
             CidrIp: 0.0.0.0/0

     MyS3Bucket:
       Type: 'AWS::S3::Bucket'
   ```
   - **Explanation**: The template provisions an EC2 instance, an S3 bucket, and a security group that allows SSH access on port 22. The `InstanceType` is set to `t2.micro` to use free-tier eligible resources.

2. **Sub-step 2**: Save the template as `cloudformation-template.yaml` on your local machine.
   - **Explanation**: The template will be used to create and manage infrastructure via CloudFormation.

### **Step 2: Deploy CloudFormation Stack**

1. **Sub-step 1**: Navigate to the **CloudFormation** service in the AWS Management Console.
    - Click **Create stack** and choose **With new resources (standard)**.
    - Select **Upload a template file** and upload the `cloudformation-template.yaml` file.
    - **Explanation**: CloudFormation uses the uploaded template to define the resources to be provisioned in the AWS environment.

2. **Sub-step 2**: Provide a **stack name** (e.g., `MyCloudFormationStack`) and configure stack options as needed.
    - Leave the default values for the remaining options, ensuring that the stack is deployed in the **ap-south-1** region.
    - **Explanation**: The stack name helps manage and track the resources created by this specific CloudFormation template.

3. **Sub-step 3**: Review the configuration and click **Create stack**. Wait for CloudFormation to provision the resources.
    - **Explanation**: CloudFormation will automatically create the EC2 instance, S3 bucket, and security group based on the defined template.

### **Step 3: Verify the Stack and Resources**

1. **Sub-step 1**: Once the stack is successfully created, navigate to the **Resources** tab in the CloudFormation console to see all provisioned resources.
    - Check that the EC2 instance, security group, and S3 bucket are listed.
    - **Explanation**: This verifies that CloudFormation has deployed all resources as expected.

2. **Sub-step 2**: Go to the **EC2 console** and verify that the EC2 instance is running. You can also check that the correct security group is applied.
    - **Explanation**: This confirms that the EC2 instance was created successfully with the correct network security configuration.

3. **Sub-step 3**: In the **S3 console**, check that the new S3 bucket exists.
    - **Explanation**: This ensures that the S3 bucket was provisioned as part of the stack.

---

## Testing and Validation

1. **Test EC2 Instance**: 
   - SSH into the EC2 instance using the key pair specified in the template.
   - Run a few commands like `sudo yum update` to ensure the instance is functional.
   - Example SSH command:
     ```bash
     ssh -i /path/to/my-key-pair.pem ec2-user@<EC2-Instance-IP>
     ```

2. **Test S3 Bucket**: 
   - Upload a test file to the S3 bucket and check that it appears in the bucket.
   - Example command using AWS CLI:
     ```bash
     aws s3 cp testfile.txt s3://my-s3-bucket-name/
     ```

3. **Validate CloudFormation Stack**:
   - Check the CloudFormation **Stack Events** to ensure there are no errors during the creation process.
   - Review the outputs and logs in the **CloudFormation** console to confirm that all resources were created as expected.

---

## Clean Resources:

1. **Delete CloudFormation Stack**: 
   - Go to the **CloudFormation** console and select the stack.
   - Click **Delete stack** to remove all resources created by the stack.
   - **Explanation**: Deleting the stack will automatically delete the EC2 instance, security group, and S3 bucket, ensuring no residual costs.

2. **Clean Up Data in S3 Bucket**:
   - If needed, manually delete any objects that were uploaded to the S3 bucket before deleting the stack.

---

## Checklist:

- [ ] Create and upload the CloudFormation template.
- [ ] Deploy the CloudFormation stack.
- [ ] Verify that the EC2 instance, security group, and S3 bucket are created.
- [ ] Test the EC2 instance by SSH and test S3 by uploading files.
- [ ] Clean up the resources by deleting the stack.

---

## Scripts (Optional):

To automate the deployment of CloudFormation stacks using the AWS CLI, you can use the following script:
```bash
# Deploy the CloudFormation stack
aws cloudformation create-stack --stack-name MyCloudFormationStack --template-body file://cloudformation-template.yaml

# Check stack status
aws cloudformation describe-stacks --stack-name MyCloudFormationStack
```