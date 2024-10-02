# 08-serverless-lambda-api-gateway-dynamodb

## Overview
This project demonstrates how to build a fully serverless API using AWS Lambda for computing, API Gateway for handling REST API endpoints, and DynamoDB for data storage.

---

### **Why?**
- **Why are we using it?**  
  Serverless architecture is scalable, cost-efficient, and requires less operational overhead. Using Lambda with API Gateway allows automatic scaling with minimal management. DynamoDB provides low-latency NoSQL storage, perfect for dynamic serverless workloads.

---

### **What?**
- **What is it and its functionality?**  
  - **AWS Lambda**: Runs code in response to API requests, with no need to manage servers.
  - **API Gateway**: Provides a RESTful API endpoint for your Lambda functions.
  - **DynamoDB**: A NoSQL database for storing application data, offering fast and consistent performance.

---

## Instructions:

### **Step 1: Create DynamoDB Table (Using AWS Console)**

1. Log into the **AWS Management Console** and navigate to **DynamoDB**.
2. Click **Create Table**.
3. Set the **Table Name** to `ItemsTable`.
4. Set the **Partition Key** to `id` (String).
5. Leave all other settings as default and click **Create**.
6. Once the table is created, it will be used by your Lambda functions to store and retrieve data.

   ### OR

### DynamoDB Table Creation (Using AWS CLI):

```bash
aws dynamodb create-table \
    --table-name ItemsTable \
    --attribute-definitions AttributeName=id,AttributeType=S \
    --key-schema AttributeName=id,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST

```

### **Step 2: Create Lambda Functions**

We will create four Lambda functions for different CRUD operations: Create, Read, Update, and Delete. Use the code below for each.

#### **1. POST (Create an Item):**

```javascript
const AWS = require('aws-sdk');
const dynamoDB = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event) => {
    const { id, name } = JSON.parse(event.body);
    const params = {
        TableName: 'ItemsTable',
        Item: { id, name }
    };

    try {
        await dynamoDB.put(params).promise();
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

#### **2. GET (Retrieve an Item):**

```javascript
const AWS = require('aws-sdk');
const dynamoDB = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event) => {
    const { id } = event.pathParameters;
    const params = {
        TableName: 'ItemsTable',
        Key: { id }
    };

    try {
        const result = await dynamoDB.get(params).promise();
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

#### **3. PUT (Update an Item):**

```javascript
const AWS = require('aws-sdk');
const dynamoDB = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event) => {
    const { id, name } = JSON.parse(event.body);
    const params = {
        TableName: 'ItemsTable',
        Key: { id },
        UpdateExpression: "set name = :name",
        ExpressionAttributeValues: { ":name": name },
        ReturnValues: "UPDATED_NEW"
    };

    try {
        const result = await dynamoDB.update(params).promise();
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

#### **4. DELETE (Delete an Item):**

```javascript
const AWS = require('aws-sdk');
const dynamoDB = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event) => {
    const { id } = event.pathParameters;
    const params = {
        TableName: 'ItemsTable',
        Key: { id }
    };

    try {
        await dynamoDB.delete(params).promise();
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

### **Step 3: Configure API Gateway**

1. Open the **API Gateway** console.
2. Create a new **REST API**.
3. Add a resource `/items` and configure the following methods:
   - **POST** (for creating items)
   - **GET** (for retrieving items by ID)
   - **PUT** (for updating items)
   - **DELETE** (for deleting items)
4. Link each method to its respective Lambda function by selecting **Lambda Function** as the integration type.
5. Deploy the API and note the API Gateway endpoint URL for testing.

### **Step 4: Testing the API**

You can test the API using **CURL** commands or a **HTML front-end**.

#### **CURL Commands**:

- **Create an Item (POST)**:
   ```bash
   curl -X POST https://your-api-url/items \
   -H "Content-Type: application/json" \
   -d '{"id": "1", "name": "Item 1"}'
   ```

- **Retrieve an Item (GET)**:
   ```bash
   curl -X GET https://your-api-url/items/1
   ```

- **Update an Item (PUT)**:
   ```bash
   curl -X PUT https://your-api-url/items \
   -H "Content-Type: application/json" \
   -d '{"id": "1", "name": "Updated Item 1"}'
   ```

- **Delete an Item (DELETE)**:
   ```bash
   curl -X DELETE https://your-api-url/items/1
   ```

### **HTML Front-End**:

#### Ensure to modify `your-api-url` in below code with your api url.

```html
<!DOCTYPE html>
<html>
<head>
    <title>Item Management</title>
    <script>
        async function createItem() {
            const id = document.getElementById('createId').value;
            const name = document.getElementById('createName').value;

            const response = await fetch('https://your-api-url/items', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ id: id, name: name })
            });
            alert(await response.text());
        }

        async function updateItem() {
            const id = document.getElementById('updateId').value;
            const name = document.getElementById('updateName').value;

            const response = await fetch('https://your-api-url/items', {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ id: id, name: name })
            });
            alert(await response.text());
        }

        async function deleteItem() {
            const id = document.getElementById('deleteId').value;

            const response = await fetch(`https://your-api-url/items/${id}`, {
                method: 'DELETE'
            });
            alert(await response.text());
        }

        async function getItem() {
            const id = document.getElementById('getId').value;

            const response = await fetch(`https://your-api-url/items/${id}`);
            const data = await response.json();
            alert(JSON.stringify(data));
        }
    </script>
</head>
<body>
    <h2>Create Item</h2>
    <input type="text" id="createId" placeholder="ID">
    <input type="text" id="createName" placeholder="Name">
    <button onclick="createItem()">Create</button>

    <h2>Update Item</h2>
    <input type="text" id="updateId" placeholder="ID">
    <input type="text" id="updateName" placeholder="New Name">
    <button onclick="updateItem()">Update</button>

    <h2>Delete Item</h2>
    <input type="text" id="deleteId" placeholder="ID">
    <button onclick="deleteItem()">Delete</button>

    <h2>Get Item</h2>
    <input type="text" id="getId" placeholder="ID">
    <button onclick="getItem()">Get</button>
</body>
</html>
```

### **Step 5: IAM Role Configuration**

Ensure that your Lambda functions have the necessary permissions to interact with DynamoDB. 

1. Open the **IAM** console.
2. Attach the **AmazonDynamoDBFullAccess** policy to the Lambda execution role.

---

### Hosting the HTML Front-End

You can host above HTML front-end page in S3 bucket to test the API using the following steps:

#### **Using S3 Bucket for Hosting HTML (Static Website)**

1. **Create an S3 Bucket:**
   - Open the **S3 Console**.
   - Click **Create Bucket** and provide a unique name (e.g., `my-html-hosting`).
   - Choose the region and keep all other settings default.

2. **Upload HTML File:**
   - In your newly created bucket, click **Upload**.
   - Upload the `index.html` file created in the previous step.

3. **Configure Bucket for Static Website Hosting:**
   - Go to the bucket's **Properties** tab.
   - Scroll down to **Static Website Hosting**.
   - Enable static website hosting and specify the index document as `index.html`.
   - Click **Save**.

4. **Make the Bucket Public:**
   - Go to the **Permissions** tab.
   - Edit the bucket policy to make it public (ensure the bucket policy allows `GetObject` permissions for everyone).

   Example bucket policy:
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

5. **Access the Website:**
   - Once everything is configured, you can access the HTML page using the S3 website endpoint provided under the static website hosting configuration.