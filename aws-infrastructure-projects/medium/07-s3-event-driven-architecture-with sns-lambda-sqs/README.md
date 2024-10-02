# 07-s3-event-driven-architecture-with sns-lambda-sqs

---

#### **Overview**

This project will walk you through creating and managing an S3 bucket on AWS, enabling versioning, setting lifecycle policies for cost management, and setting up event notifications using **SNS**, **Lambda**, and **SQS**. 

This project demonstrates multiple ways to manage S3 events using SNS, Lambda, and SQS. Depending on your use case, you can either send real-time notifications using SNS, run custom code using Lambda, or decouple event processing using SQS.

### **Key Benefits of Using SNS and SQS in This Project:**

- **Real-time Notifications** with SNS to inform users when S3 bucket actions occur.
- **Reliable and Scalable Event Processing** with SQS to ensure all events are captured and handled, even under high loads.
- **Decoupling:** SQS ensures that event processing is independent and not directly tied to the S3 event itself, improving system reliability.


---

#### **Table of Contents**

1. [Prerequisites](#prerequisites)
2. [Step 1: Create an S3 Bucket](#step-1-create-an-s3-bucket)
3. [Step 2: Enable Versioning](#step-2-enable-versioning)
4. [Step 3: Set Up Lifecycle Policies](#step-3-set-up-lifecycle-policies)
5. [Step 4: Upload and Manage Objects in S3](#step-4-upload-and-manage-objects-in-s3)
6. [Step 5: Configure Event Notifications (Multiple Options)](#step-5-configure-event-notifications-multiple-options)
   - [Option 1: Using SNS for Real-time Notifications](#option-1-using-sns-for-real-time-notifications)
   - [Option 2: Using Lambda for Custom Processing](#option-2-using-lambda-for-custom-processing)
   - [Option 3: Using SQS for Decoupled Event Processing](#option-3-using-sqs-for-decoupled-event-processing)
7. [Step 6: Test the Event Notification System](#step-6-test-the-event-notification-system)
8. [Best Practices Considerations](#best-practices-considerations)
9. [Conclusion](#conclusion)

---

### **Prerequisites**

- AWS Account with access to the AWS Management Console.
- Basic knowledge of S3, SNS, SQS, and Lambda.
- An email address to receive notifications via SNS (if used).

---

### **Step 1: Create an S3 Bucket**

1. **Navigate to the S3 Console:**
   - Log in to the AWS Management Console.
   - Go to **Services** > **S3**.

2. **Create a New S3 Bucket:**
   - Click **Create bucket**.
   - **Bucket Name:** Provide a unique bucket name (e.g., `my-training-bucket`).
   - **Region:** Choose a region that matches your other AWS resources.
   - **Bucket Settings:** Enable **Block Public Access** unless you need the bucket to be public.
   - Click **Create Bucket**.

---

### **Step 2: Enable Versioning**

1. **Navigate to the S3 Bucket:**
   - Select your S3 bucket from the list.

2. **Enable Versioning:**
   - Go to the **Properties** tab.
   - Scroll down to **Bucket Versioning** and click **Enable Versioning**.

---

### **Step 3: Set Up Lifecycle Policies**

1. **Navigate to Lifecycle Rules:**
   - In the **Management** tab, go to **Lifecycle rules**.
   - Click **Create lifecycle rule**.

2. **Create a Rule to Transition Objects:**
   - **Rule Name:** `MoveToGlacier`.
   - **Scope:** Apply to all objects or specify a prefix.
   - **Transitions:**
     - Transition objects to **Glacier** after 30 days.
   - **Expiration:** Set objects to expire (delete) after 365 days.
   - Click **Create Rule**.

---

### **Step 4: Upload and Manage Objects in S3**

1. **Upload Files to the S3 Bucket:**
   - Navigate to your bucket and click **Upload**.
   - Upload files as needed.

2. **Test Versioning:**
   - Upload a file (e.g., `test-file.txt`), modify it, and upload it again.
   - Check the **Versions** tab to view different versions of the file.

---

### **Step 5: Configure Event Notifications (Multiple Options)**

Based on your specific needs, there are three main options to handle **S3 event notifications**. Each option has a different use case:

---

#### **Option 1: Using SNS for Real-time Notifications**

If you want to send **real-time notifications** (e.g., email alerts) when an S3 event occurs (like an object being uploaded or deleted), you can use **SNS**.

1. **Create an SNS Topic:**
   - Go to **Services** > **Simple Notification Service (SNS)**.
   - Click **Create topic**.
   - **Topic Name:** `S3EventNotificationTopic`.
   - Choose **Standard** as the type.
   - Click **Create topic**.

2. **Create an Email Subscription:**
   - Open the topic and click **Create subscription**.
   - **Protocol:** Select **Email**.
   - **Endpoint:** Enter your email address.
   - Confirm the subscription from your inbox.

3. **Configure S3 Event Notifications for SNS:**
   - Go to your S3 bucket and click the **Properties** tab.
   - Scroll down to **Event notifications** and click **Create Event Notification**.
   - **Event Name:** `S3SNSEvent`.
   - **Events:** Select the events you want to trigger (e.g., **All object create events**).
   - **Send to SNS Topic:** Select your SNS topic (`S3EventNotificationTopic`).
   - Save the notification.

---

#### **Option 2: Using Lambda for Custom Processing**

If you want to run custom code (like logging, processing the data, or transforming it) whenever an S3 event occurs, you can use **Lambda** to trigger custom logic.

1. **Create a Lambda Function:**
   - Go to **Services** > **Lambda**.
   - **Function Name:** `S3EventProcessingLambda`.
   - **Runtime:** Choose **Python 3.x**.
   - Click **Create Function**.

2. **Add Lambda Code:**

   ```python
   import json

   def lambda_handler(event, context):
       print("Received event: " + json.dumps(event, indent=2))
       bucket_name = event['Records'][0]['s3']['bucket']['name']
       object_key = event['Records'][0]['s3']['object']['key']
       event_name = event['Records'][0]['eventName']

       # Do custom processing here, e.g., logging or transforming the data
       print(f"Bucket: {bucket_name}, Object: {object_key}, Event: {event_name}")

       return {
           'statusCode': 200,
           'body': json.dumps('Event processed successfully!')
       }
   ```

3. **Configure S3 Event Notifications for Lambda:**
   - Go to your S3 bucket and click the **Properties** tab.
   - Scroll down to **Event notifications** and click **Create Event Notification**.
   - **Event Name:** `S3LambdaEvent`.
   - **Events:** Select the events you want to trigger (e.g., **All object create events**).
   - **Send to Lambda Function:** Select your Lambda function (`S3EventProcessingLambda`).
   - Save the notification.

---

#### **Option 3: Using SQS for Decoupled Event Processing**

If you want to **decouple the processing** of S3 events and ensure that no events are lost even if they can't be processed immediately, use **SQS**. The SQS queue holds the events, and you can process them later.

1. **Create an SQS Queue:**
   - Go to **Services** > **Simple Queue Service (SQS)**.
   - **Queue Name:** `S3EventQueue`.
   - Choose **Standard** as the type.
   - Click **Create queue**.

2. **Configure S3 Event Notifications for SQS:**
   - Go to your S3 bucket and click the **Properties** tab.
   - Scroll down to **Event notifications** and click **Create Event Notification**.
   - **Event Name:** `S3SQSEvent`.
   - **Events:** Select the events you want to trigger (e.g., **All object create events**).
   - **Send to SQS Queue:** Select your SQS queue (`S3EventQueue`).
   - Save the notification.

3. **Optional:** Use **Lambda** to process messages from SQS:
   - You can configure a Lambda function to poll the SQS queue and process messages from the queue as shown below.
   - Let me walk you through what the Python code in the Lambda function is doing step by step.

        ### **Python Lambda Code Explanation**
        
        Here is the code again for reference:
        
        ```python
        import json
        import boto3
        
        sns_client = boto3.client('sns')
        sqs_client = boto3.client('sqs')
        
        SNS_TOPIC_ARN = 'arn:aws:sns:your-region:your-account-id:S3EventNotificationTopic'
        SQS_QUEUE_URL = 'https://sqs.your-region.amazonaws.com/your-account-id/S3EventQueue'
        
        def lambda_handler(event, context):
            # Log the event
            print("Received event: " + json.dumps(event, indent=2))
        
            # Extract event details
            bucket_name = event['Records'][0]['s3']['bucket']['name']
            object_key = event['Records'][0]['s3']['object']['key']
            event_name = event['Records'][0]['eventName']
        
            # Prepare the message
            message = {
                'Bucket': bucket_name,
                'ObjectKey': object_key,
                'EventName': event_name,
            }
        
            # Send message to SNS
            sns_client.publish(
                TopicArn=SNS_TOPIC_ARN,
                Message=json.dumps(message),
                Subject=f'S3 Event: {event_name}'
            )
        
            # Send message to SQS
            sqs_client.send_message(
                QueueUrl=SQS_QUEUE_URL,
                MessageBody=json.dumps(message)
            )
        
            return {
                'statusCode': 200,
                'body': json.dumps('Event processed successfully!')
            }
        ```
        
        ### **Breakdown of What the Code is Doing:**
        
        1. **Importing Required Libraries:**
           ```python
           import json
           import boto3
           ```
           - **`json`**: This is a Python module used to work with JSON data, such as converting Python objects to JSON strings.
           - **`boto3`**: This is the AWS SDK for Python, which allows you to interact with AWS services like SNS (Simple Notification Service) and SQS (Simple Queue Service).
        
        2. **Creating SNS and SQS Clients:**
           ```python
           sns_client = boto3.client('sns')
           sqs_client = boto3.client('sqs')
           ```
           - This code creates **SNS** and **SQS** client objects using `boto3`. These clients will be used later to interact with the SNS and SQS services, such as publishing messages to SNS topics or sending messages to SQS queues.
        
        3. **Defining SNS Topic ARN and SQS Queue URL:**
           ```python
           SNS_TOPIC_ARN = 'arn:aws:sns:your-region:your-account-id:S3EventNotificationTopic'
           SQS_QUEUE_URL = 'https://sqs.your-region.amazonaws.com/your-account-id/S3EventQueue'
           ```
           - **`SNS_TOPIC_ARN`**: This is the Amazon Resource Name (ARN) of the SNS topic where notifications will be published. It uniquely identifies your SNS topic.
           - **`SQS_QUEUE_URL`**: This is the URL of the SQS queue where messages will be sent.
        
        4. **Lambda Handler Function:**
           ```python
           def lambda_handler(event, context):
               ...
           ```
           - **`lambda_handler`**: This is the entry point of the Lambda function. AWS Lambda automatically invokes this function when an S3 event occurs. It takes two parameters:
             - **`event`**: This contains details about the S3 event that triggered the Lambda function.
             - **`context`**: This contains information about the runtime environment of the Lambda function.
        
        5. **Logging the Event:**
           ```python
           print("Received event: " + json.dumps(event, indent=2))
           ```
           - This line logs the S3 event to the console (which you can see in AWS CloudWatch). It converts the `event` dictionary to a JSON-formatted string for better readability.
        
        6. **Extracting Details from the Event:**
           ```python
           bucket_name = event['Records'][0]['s3']['bucket']['name']
           object_key = event['Records'][0]['s3']['object']['key']
           event_name = event['Records'][0]['eventName']
           ```
           - **`event['Records'][0]`**: The `event` contains a `Records` array, and we're accessing the first record (`[0]`), which contains details about the specific S3 event (e.g., object creation, deletion).
           - **`bucket_name`**: Extracts the name of the S3 bucket where the event occurred.
           - **`object_key`**: Extracts the key (i.e., the path or filename) of the object that was affected in the S3 bucket.
           - **`event_name`**: Extracts the type of event that occurred, such as `ObjectCreated:Put` (for file uploads) or `ObjectRemoved:Delete` (for file deletions).
        
        7. **Preparing the Message:**
           ```python
           message = {
               'Bucket': bucket_name,
               'ObjectKey': object_key,
               'EventName': event_name,
           }
           ```
           - This creates a Python dictionary containing information about the S3 event. The message includes the name of the bucket, the key (filename) of the object, and the type of event (create, delete, etc.).
        
        8. **Sending the Message to SNS:**
           ```python
           sns_client.publish(
               TopicArn=SNS_TOPIC_ARN,
               Message=json.dumps(message),
               Subject=f'S3 Event: {event_name}'
           )
           ```
           - **`sns_client.publish`**: This publishes the event details to the SNS topic. The `TopicArn` specifies where to send the message.
           - **`Message`**: The message being sent to the SNS topic. It's converted to JSON format using `json.dumps(message)`.
           - **`Subject`**: This is the subject of the message, which includes the event name (e.g., "S3 Event: ObjectCreated:Put").
        
        9. **Sending the Message to SQS:**
           ```python
           sqs_client.send_message(
               QueueUrl=SQS_QUEUE_URL,
               MessageBody=json.dumps(message)
           )
           ```
           - **`sqs_client.send_message`**: This sends the event details as a message to the SQS queue.
           - **`QueueUrl`**: The URL of the SQS queue where the message will be sent.
           - **`MessageBody`**: The body of the message, which contains the event details in JSON format.
        
        10. **Returning a Success Response:**
           ```python
           return {
               'statusCode': 200,
               'body': json.dumps('Event processed successfully!')
           }
           ```
           - This returns an HTTP 200 status code, indicating that the Lambda function executed successfully.
        
        ---
        
        ### **Summary of What the Code Does:**
        
        1. **Receives an S3 Event:** The Lambda function is triggered whenever an event occurs in the S3 bucket (such as an object being created or deleted).
        2. **Extracts Event Details:** The function extracts key details from the event (such as the bucket name, object key, and event type).
        3. **Sends Notifications:**
           - **Publishes a message to SNS**: Sends a notification with the event details to an SNS topic (which can notify subscribers, such as sending an email).
           - **Sends a message to SQS**: Sends the event details to an SQS queue for further processing.
        4. **Logs the Event and Returns Success:** The function logs the event details and returns a success response.
        
        This code helps build an event-driven architecture by allowing real-time notifications (via SNS) and decoupled processing (via SQS) for any events occurring in the S3 bucket.

---

### **Step 6: Test the Event Notification System**

1. **For SNS Notifications:**
   - Upload a file to the S3 bucket, and check your email for the SNS notification.
   
2. **For Lambda Processing:**
   - Upload a file, and check AWS CloudWatch logs to see if Lambda processed the event.

3. **For SQS Queuing:**
   - Upload a file, and then check the SQS queue for the new message. Optionally, set up Lambda to process the message.

---

### **Best Practices Considerations**

- **Security:** Ensure your IAM roles only have the permissions they need (principle of least privilege).
- **Cost Optimization:** Use lifecycle policies to automatically move infrequently accessed data to Glacier or delete expired objects.
- **Monitoring:** Use AWS CloudWatch to monitor the performance of your Lambda functions.