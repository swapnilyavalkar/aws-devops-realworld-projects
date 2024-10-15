# 03 - Security Best Practices: IAM

## Overview:
In this project, we will implement AWS Identity and Access Management (IAM) security best practices to secure your AWS environment. IAM allows fine-grained control over user permissions and access to AWS resources. This project covers configuring multi-factor authentication (MFA), setting up IAM roles and policies with the least privilege principle, managing access keys securely, and logging IAM activities for monitoring and compliance.

**Technologies used:**
- **IAM (Identity and Access Management)**: Service to manage access to AWS resources.
- **AWS CloudTrail**: Logs API calls to track IAM activities.
- **AWS Management Console**: Interface to manage IAM users, roles, and policies.

**Key objectives:**
- Implement IAM best practices like least privilege, MFA, and access key rotation.
- Enable logging and monitoring of IAM activities.
- Ensure the security of AWS accounts and resources through IAM best practices.

## Real-Life Use Case:
IAM security best practices are critical for organizations to protect their AWS environments from unauthorized access. For example, a financial services company using AWS to manage customer data needs to enforce strict access controls, audit trails, and role-based access to ensure compliance with industry regulations like GDPR or HIPAA.

## Why and What: Tools and Their Functionality?

1. **IAM**: IAM is the core service for managing users, roles, and permissions. It enforces security through policies, MFA, and role-based access control, helping organizations restrict access to sensitive data and resources.

2. **CloudTrail**: CloudTrail logs IAM activities, providing an audit trail of API calls. This is essential for monitoring who accessed what resources and when, ensuring accountability and helping with compliance.

3. **MFA (Multi-Factor Authentication)**: Adding an extra layer of security for AWS users, MFA ensures that even if credentials are compromised, the account remains secure by requiring additional verification.

4. **IAM Roles and Policies**: Roles are used to grant temporary access to AWS resources without sharing credentials, following the least privilege principle.

## Setup Instructions

### **Step 1: Set Up IAM Users and Groups**

1. **Sub-step 1**: Navigate to **IAM** in the AWS Management Console.
    - Create an **IAM group** with the necessary permissions for different roles (e.g., admin, developer, auditor).
    - Assign policies such as `AdministratorAccess`, `PowerUserAccess`, or custom policies based on the role’s requirements.
    - **Explanation**: Grouping users with specific policies helps manage permissions efficiently and ensures users have the minimum required access.

2. **Sub-step 2**: Create **IAM users** and assign them to the respective groups. 
    - Ensure that **console access** is enabled for users who need to log in to the AWS Management Console, and programmatic access (API/CLI access) is enabled for developers.
    - **Explanation**: This step assigns the correct level of access to users based on their roles in the organization, ensuring role-based access.

### **Step 2: Enable MFA for All IAM Users**

1. **Sub-step 1**: In the **IAM Users** section, select each user, and under the **Security credentials** tab, enable **MFA**.
    - Use a virtual MFA device (like Google Authenticator) or a hardware MFA device.
    - **Explanation**: Enabling MFA adds an extra layer of security to protect user accounts in case login credentials are compromised.

2. **Sub-step 2**: Follow the steps to scan the QR code with the MFA app and set up MFA for each user.
    - **Explanation**: This step ensures the MFA process is completed and enabled for the user.

### **Step 3: Apply Least Privilege for IAM Policies**

1. **Sub-step 1**: Review all existing policies in the **IAM Policies** section. Ensure each policy grants the least privilege required for each role or user group.
    - For example, developers should only have access to resources necessary for development, not full admin access.
    - **Explanation**: The principle of least privilege ensures that users only have the necessary permissions, reducing the risk of accidental or malicious changes.

2. **Sub-step 2**: Create **custom policies** as needed to limit access to specific resources, such as particular S3 buckets or EC2 instances.
    - Use the **Policy Generator** or **JSON Editor** to write fine-grained policies.
    - **Explanation**: Custom policies allow you to enforce tighter controls over resources, ensuring only authorized actions can be performed.

### **Step 4: Secure Access Keys and Rotate Regularly**

1. **Sub-step 1**: For any users who require programmatic access, create **access keys** in the **Security Credentials** tab.
    - Ensure the user rotates their access keys regularly (e.g., every 90 days).
    - **Explanation**: Access keys can be compromised, so rotating them regularly ensures that stale keys are not exposed to attackers.

2. **Sub-step 2**: Enable **CloudTrail** to log the creation, usage, and rotation of access keys. Use **AWS Config** to set up rules for access key rotation and notify users when a rotation is needed.
    - **Explanation**: This step ensures that access keys are monitored and tracked, providing visibility into when they are used or rotated.

### **Step 5: Enable CloudTrail Logging for IAM Activities**

1. **Sub-step 1**: In the **CloudTrail** console, enable a **new trail** or verify that an existing trail is logging all IAM API calls.
    - Ensure **S3 Data Events** and **IAM Data Events** are enabled.
    - **Explanation**: Logging IAM activities ensures that all access to resources is tracked and can be audited in the event of a security breach.

2. **Sub-step 2**: Set up **CloudWatch Alarms** to notify administrators of any suspicious IAM activity (e.g., multiple failed login attempts or unauthorized API calls).
    - **Explanation**: This provides real-time monitoring of IAM actions, helping prevent potential security incidents.

---

## Testing and Validation

1. **MFA Testing**: Attempt to log in to an IAM user account after enabling MFA. The system should prompt for the MFA code.
    - Test by entering the correct MFA code and verify login success.
    - Test by entering an incorrect MFA code and verify that access is denied.

2. **Access Key Usage**: Use the AWS CLI to issue a command (e.g., listing S3 buckets) with the user's access keys. Ensure that the command succeeds and logs are recorded in CloudTrail.

3. **CloudTrail Logs**: Navigate to **CloudTrail Event History** and filter events by `iam.amazonaws.com` to verify that IAM-related activities are being logged.

---

Enabling MFA and rotating access keys for a large number of users, requires automation and careful management. Here’s how you can achieve this using AWS services and automation tools.

### **1. Enabling MFA for large number of users**

To enable MFA for such a large number of users, you can automate the process using AWS SDKs (like Boto3 for Python) or AWS CLI along with scripts and AWS Lambda functions.

#### **Steps for Enabling MFA Using a Script:**

1. **List All Users:**
   - Use the AWS CLI or Boto3 to get a list of all IAM users in your AWS account.
   
   AWS CLI Command:
   ```bash
   aws iam list-users --query 'Users[*].UserName' --output text
   ```

2. **Create Virtual MFA Devices for Users:**
   - For each user, create a virtual MFA device and associate it with their account.

   Boto3 (Python) Example:
   ```python
   import boto3

   iam_client = boto3.client('iam')

   users = iam_client.list_users()
   for user in users['Users']:
       mfa_device = iam_client.create_virtual_mfa_device(VirtualMFADeviceName=f"{user['UserName']}-mfa")
       iam_client.enable_mfa_device(
           UserName=user['UserName'],
           SerialNumber=mfa_device['VirtualMFADevice']['SerialNumber'],
           AuthenticationCode1='123456',
           AuthenticationCode2='654321'
       )
   ```
   - In this script, you need to scan the QR code or distribute it to users to configure their MFA devices. You can integrate this with an internal user notification system or email.

3. **Notify Users to Activate MFA:**
   - After creating the virtual MFA devices, you can email the users with instructions on how to scan the QR code using an MFA app (e.g., Google Authenticator or Authy).

4. **Automate Distribution:**
   - Use AWS SNS or SES to send notifications/emails to each user, guiding them to enable MFA on their devices.

#### **Alternative Approach with AWS SSO (If Applicable):**
If your organization uses AWS SSO (Single Sign-On), you can enforce MFA at the SSO level for all users. This is a more centralized approach and scales better for large numbers of users.

### **2. Rotating Access Keys for large number of users**

For rotating access keys regularly, AWS provides AWS Config and Lambda to automate and enforce access key rotation.

#### **Steps for Automating Access Key Rotation:**

1. **Monitor Key Age Using AWS Config:**
   - Set up an **AWS Config rule** to monitor the age of IAM access keys.
   - The rule `iam-user-no-unused-credentials-check` monitors user credentials, including access keys.
   - You can configure a compliance rule to trigger if an access key is older than 90 days.

2. **Automate Key Rotation Using Lambda:**
   - Write an AWS Lambda function that is triggered by the AWS Config rule to automatically rotate access keys for users when they reach the 90-day threshold.
   - The Lambda function will:
     1. Create a new access key for the user.
     2. Disable or delete the old access key.
     3. Notify the user of the new key.

   Boto3 (Python) Example for Rotating Keys:
   ```python
   import boto3

   iam_client = boto3.client('iam')

   def rotate_access_key(user_name):
       # Create new access key
       response = iam_client.create_access_key(UserName=user_name)
       new_access_key = response['AccessKey']['AccessKeyId']
       new_secret_key = response['AccessKey']['SecretAccessKey']

       # List old access keys
       access_keys = iam_client.list_access_keys(UserName=user_name)
       for key in access_keys['AccessKeyMetadata']:
           if key['Status'] == 'Active':
               # Deactivate old key
               iam_client.update_access_key(UserName=user_name, AccessKeyId=key['AccessKeyId'], Status='Inactive')
               # Optionally, delete the old key
               # iam_client.delete_access_key(UserName=user_name, AccessKeyId=key['AccessKeyId'])

       # Notify user of new access key
       # Use SNS or SES to send new access key details to the user

   # Example usage
   rotate_access_key('test-user')
   ```
   This script will create a new access key for the user, deactivate the old key, and send a notification to the user.

3. **Notify Users:**
   - Use **AWS SNS** or **AWS SES** to notify users of the new access key.
   - You can automate this within the Lambda function to send an email or notification to each user.

4. **Automate Key Rotation Across All Users:**
   - Schedule the Lambda function to run daily or weekly, depending on your user base, and rotate keys that are older than 90 days.
   - Use the following CloudWatch rule to trigger the Lambda function every 90 days:
   ```bash
   aws events put-rule --schedule-expression "rate(90 days)" --name "rotate-access-keys-rule"
   ```

#### **Best Practices for Scaling Key Rotation and MFA:**
- **Limit Access Key Usage**: Where possible, use IAM roles and avoid long-term access keys. IAM roles automatically rotate credentials when used with EC2 or other AWS services.
- **Centralized Logging**: Use AWS CloudTrail to log all IAM actions, including MFA changes and access key creation/deletion.
- **Key Deactivation Before Deletion**: Before deleting old keys, ensure they are disabled and monitored to avoid disrupting user operations.

By combining AWS Config, Lambda, SNS/SES, and monitoring tools like CloudTrail, you can efficiently manage MFA and access key rotation for a large number of users.

## Checklist:

- [ ] Create IAM users and groups with the least privilege.
- [ ] Enable MFA for all IAM users.
- [ ] Apply least privilege principles to all IAM policies.
- [ ] Rotate access keys and enable CloudTrail logging for key usage.
- [ ] Monitor IAM activities with CloudTrail and CloudWatch.

---

## Clean Resources:

1. **Disable MFA**: Go to each IAM user and disable MFA.
2. **Delete IAM Users**: Remove all test IAM users and their access keys.
3. **Delete IAM Groups**: Delete the IAM groups created for the project.
4. **Disable CloudTrail**: If you set up a trail specifically for this project, disable it to avoid unnecessary logging charges.

---

## Scripts (Optional):

You can use AWS CLI commands to automate some IAM operations. Here’s an example script to create an IAM user, assign them to a group, and enable MFA:
```bash
# Create IAM user
aws iam create-user --user-name test-user

# Add user to group
aws iam add-user-to-group --user-name test-user --group-name admin-group

# Create MFA device for the user
aws iam create-virtual-mfa-device --virtual-mfa-device-name test-user-mfa
```