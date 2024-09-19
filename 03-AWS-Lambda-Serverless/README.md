# Serverless API using AWS Lambda, API Gateway, and DynamoDB

## Overview:

This project demonstrates how to build a fully serverless API using AWS Lambda for computing, API Gateway for handling REST API endpoints, and DynamoDB for data storage. Additionally, we'll create a simple HTML front-end hosted on S3 to interact with the API.

## Why are we using it?
  Serverless architecture is scalable, cost-efficient, and requires less operational overhead. Using **Lambda** with **API Gateway** allows automatic scaling with minimal management. **DynamoDB** provides low-latency NoSQL storage, perfect for dynamic serverless workloads.

## What is it and its functionality?
  - **AWS Lambda**: Runs code in response to API requests, with no need to manage servers.
  - **API Gateway**: Provides a RESTful API endpoint for your Lambda functions.
  - **DynamoDB**: A NoSQL database for storing application data, offering fast and consistent performance.
  - **HTML Front-End**: A simple web interface hosted on S3 that interacts with the API.

## Real-Life Use Case:
At companies like **Amazon**, various serverless APIs are used to handle order management, user profiles, and inventory updates. For example, when a user places an order, an **API Gateway** triggers a **Lambda function** that saves order details in a **DynamoDB** table. This architecture allows Amazon to automatically scale based on user traffic and ensures low latency and high availability without managing any servers. The HTML front-end enables internal teams to interact with the API for testing and monitoring.

---
## Setup Instructions

### **Step 1: Create DynamoDB Table (Using AWS Console)**

1. Log into the **AWS Management Console** and navigate to **DynamoDB**.
2. Click **Create Table**.
3. Set the **Table Name** to `ItemsTable`.
4. Set the **Partition Key** to `id` (String).
5. Leave all other settings as default and click **Create**.

   ### OR
### DynamoDB Table Creation (Using AWS CLI):

```bash
aws dynamodb create-table \
    --table-name ItemsTable \
    --attribute-definitions AttributeName=id,AttributeType=S \
    --key-schema AttributeName=id,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST
```

---

### **Step 2: Create an IAM Role in AWS Console**

 1. **Create a New Role:**
   - In the **IAM Dashboard**, on the left-hand side, click **Roles**.
   - Click the **Create Role** button at the top of the Roles page.

 2. **Select the Trusted Entity:**
   - For the **Trusted Entity**, select **AWS Service**.
   - Under **Use Case**, select **Lambda** as the trusted service (since you will be attaching this role to your Lambda functions).
   - Click **Next**.

 3. **Attach Required Policies:**
   - On the **Attach permissions policies** page, search for the required policies by name and select them:
     - **AmazonAPIGatewayInvokeFullAccess**: Allows API Gateway to invoke Lambda.
     - **AmazonDynamoDBFullAccess**: Allows Lambda to perform CRUD operations on DynamoDB.
     - **AWSLambda_FullAccess**: Grants Lambda full access to manage its execution.
     - **CloudWatchLogsFullAccess**: Allows Lambda to create and write logs in CloudWatch.

   - Once you've selected all the required policies, click **Next**.

 4. **Set Role Name and Tags (Optional):**
   - On the **Name, Review, and Create** page, give your role a descriptive name, such as:
     - `Lambda-CRUD-DynamoDB-Role`
   - Optionally, you can add tags to organize and categorize your roles.
   - Click **Create Role**.

---

### **Step 2: Create Lambda Functions**

You will create four Lambda functions for different CRUD operations: **Create, Read, Update, and Delete**. Use the code below for each. Please ensure to select `Lambda-CRUD-DynamoDB-Role` under `Change Default Execution Role` for each function while creating them. 

#### **1. POST (Create an Item)**

```javascript
import { DynamoDBClient, PutItemCommand } from "@aws-sdk/client-dynamodb";

const client = new DynamoDBClient({ region: "ap-south-1" });

export const handler = async (event) => {
    try {
        // Safely parse the event.body, handle cases where it's undefined
        let body = event.body;
        if (body) {
            if (typeof body === "string") {
                body = JSON.parse(body);
            }
        } else {
            throw new Error("Missing request body");
        }

        const { id, name } = body;

        if (!id || !name) {
            throw new Error("Missing 'id' or 'name' in the request body");
        }

        const params = {
            TableName: "ItemsTable",
            Item: {
                id: { S: id },
                name: { S: name }
            }
        };

        const command = new PutItemCommand(params);
        await client.send(command);

        return {
            statusCode: 200,
            body: JSON.stringify({ message: "Item created successfully" })
        };
    } catch (err) {
        return {
            statusCode: 500,
            body: JSON.stringify({ error: err.message })
        };
    }
};

```

#### **2. GET (Retrieve an Item)**

```javascript
import { DynamoDBClient, GetItemCommand } from "@aws-sdk/client-dynamodb";

// Create DynamoDB client
const client = new DynamoDBClient({ region: "ap-south-1" });

export const handler = async (event) => {
    try {
        // Get the 'id' from path parameters
        const { id } = event.pathParameters;

        if (!id) {
            throw new Error("Missing 'id' in the path parameters");
        }

        const params = {
            TableName: "ItemsTable",
            Key: {
                id: { S: id }  // Dynamodb expects keys to be formatted as {type: value}
            }
        };

        // Use the GetItemCommand to retrieve the item from DynamoDB
        const command = new GetItemCommand(params);
        const result = await client.send(command);

        if (!result.Item) {
            return {
                statusCode: 404,
                body: JSON.stringify({ message: "Item not found" })
            };
        }

        return {
            statusCode: 200,
            body: JSON.stringify(result.Item)
        };
    } catch (err) {
        return {
            statusCode: 500,
            body: JSON.stringify({ error: err.message })
        };
    }
};

```

#### **3. PUT (Update an Item)**

```javascript
import { DynamoDBClient, UpdateItemCommand } from "@aws-sdk/client-dynamodb";

const client = new DynamoDBClient({ region: "ap-south-1" });

export const handler = async (event) => {
    try {
        // Get 'id' from pathParameters
        const id = event.pathParameters && event.pathParameters.id;

        // Safely parse the event.body for 'name'
        let body = event.body;
        if (body) {
            if (typeof body === "string") {
                body = JSON.parse(body);
            }
        } else {
            throw new Error("Missing request body");
        }

        const { name } = body;

        if (!id || !name) {
            throw new Error("Missing 'id' or 'name' in the request body or path");
        }

        const params = {
            TableName: "ItemsTable",
            Key: {
                id: { S: id }
            },
            UpdateExpression: "SET #name = :name",
            ExpressionAttributeNames: {
                "#name": "name"
            },
            ExpressionAttributeValues: {
                ":name": { S: name }
            },
            ReturnValues: "UPDATED_NEW"
        };

        const command = new UpdateItemCommand(params);
        const result = await client.send(command);

        return {
            statusCode: 200,
            body: JSON.stringify(result.Attributes)
        };
    } catch (err) {
        return {
            statusCode: 500,
            body: JSON.stringify({ error: err.message })
        };
    }
};

```

#### **4. DELETE (Delete an Item)**

```javascript
import { DynamoDBClient, DeleteItemCommand } from "@aws-sdk/client-dynamodb";

const client = new DynamoDBClient({ region: "ap-south-1" });

export const handler = async (event) => {
    try {
        // Get 'id' from path parameters
        const id = event.pathParameters && event.pathParameters.id;

        if (!id) {
            return {
                statusCode: 400,
                body: JSON.stringify({ error: "Missing 'id' in path parameters" })
            };
        }

        const params = {
            TableName: "ItemsTable",
            Key: {
                id: { S: id }
            }
        };

        const command = new DeleteItemCommand(params);
        await client.send(command);

        return {
            statusCode: 200,
            body: JSON.stringify({ message: "Item deleted successfully" })
        };

    } catch (err) {
        return {
            statusCode: 500,
            body: JSON.stringify({ error: err.message })
        };
    }
};

```

---

### **Step 3: Configure API Gateway**

1. Open the **API Gateway** console.
2. Create a new **REST API**.
3. Add a resource `/items` under root `\` and configure the following method under `/items`:
   - **POST** (for creating items)
        - **Method**: POST
        - **Integration Type**: Lambda function
        - **Lambda Proxy Integration**: **Enabled**
        - **Lambda function**: Select your lambda function for creating items.
4. Add a resource `{id}` under root `/items` and configure the following methods under `/{id}`:
   - **GET** (for retrieving items by ID)
        - **Method**: GET
        - **Integration Type**: Lambda function
        - **Lambda Proxy Integration**: **Enabled**
        - **Lambda function**: Select your lambda function for getting items.

   - **PUT** (for updating items)
        - **Method**: PUT
        - **Integration Type**: Lambda function
        - **Lambda Proxy Integration**: **Enabled**
        - **Lambda function**: Select your lambda function for updating items.

   - **DELETE** (for deleting items)
        - **Method**: DELETE
        - **Integration Type**: Lambda function
        - **Lambda Proxy Integration**: **Enabled**
        - **Lambda function**: Select your lambda function for deleting items.
4. Deploy the API, create a new stage `Dev` and note the API Gateway endpoint URL for testing.

---

### **Step 4: Testing the API**

You can test the API using **CURL** commands or an **HTML front-end**.

#### **CURL Commands**:

- **Create an Item (POST)**:
   #### **cURL Command**:
    ```bash
    $ curl -k -X POST https://<API_ID>.execute-api.ap-south-1.amazonaws.com/dev/items \
    -H "Content-Type: application/json" \
    -d '{"id": "1", "name": "Item 1"}'
    ```

- **Retrieve an Item (GET)**:
   #### **cURL Command**:
    ```bash
    $ curl -k -X GET https://<API_ID>.execute-api.ap-south-1.amazonaws.com/dev/items/1
    ```

- **Update an Item (PUT)**:
   #### **cURL Command**:
    ```bash
    $ curl -k -X PUT https://<API_ID>.execute-api.ap-south-1.amazonaws.com/dev/items/1 \
    -H "Content-Type: application/json" -d '{"name": "Updated Item Name"}'
    ```

- **Delete an Item (DELETE)**:
   #### **cURL Command**:
    ```bash
    $ curl -k -X DELETE https://<API_ID>.execute-api.ap-south-1.amazonaws.com/dev/items/1
    ```

---

### **Step 5: HTML Front-End** (Optional)

You can host the **![HTML](./scripts/index.html)** page in an **S3** bucket to test the API through a front-end interface.

1. **Create an S3 Bucket with Public Access:**
   - Open the **S3 Console**.
   - Click **Create Bucket** and provide a unique name (e.g., `my-html-hosting`).

2. **Upload HTML File:**
   - Upload the **![HTML](./scripts/index.html)** file.

3. **Configure Bucket for Static Website Hosting:**
   - Enable **Static Website Hosting** under **Properties**.

4. **Make the Bucket Public:**
   - Set the correct bucket policy for public access to the `index.html`.
    ```json
        {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": "*",
                "Action": "s3:GetObject",
                "Resource": "arn:aws:s3:::my-html-hosting/*"
            }
        ]
    }
    ```

---

### Screenshots:


---
### Conclusion:
In this project, we successfully built a serverless API using AWS Lambda, API Gateway, and DynamoDB. We also created a simple HTML front-end to interact with the API, which is hosted in an S3 bucket. This approach showcases how to manage CRUD operations and leverage serverless technologies effectively.

---
