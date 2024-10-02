# 09-serverless-container-lambda

## Objective:
The goal of this part is to deploy your new web application with a contact form, convert it into a microservice using AWS Lambda, and expose it via API Gateway. The web app will interact with the Lambda function, sending form data for processing, and you will deploy the app on AWS ECS using Fargate.

---

## Instructions:

### **Step 1: Create the Web Application**

You will build a simple **contact form web app** that submits form data (name, email, message) to AWS Lambda via API Gateway.

1. **Set up the project structure** on your local machine:

    ```bash
    git clone https://github.com/swapnilyavalkar/aws-lambda-contact-form.git
    cd aws-lambda-contact-form
    ```

   ```
   /aws-lambda-contact-form
   ├── index.html
   ├── Dockerfile
   ├── package.json
   └── (other files if necessary)
   ```

#### 1.1 **HTML - `index.html`**

[Index.html](https://github.com/swapnilyavalkar/aws-lambda-contact-form/blob/main/index.html) file contains the contact form and client-side JavaScript to send the form data to the AWS API Gateway.

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Contact Form</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f7f7f7;
            padding: 20px;
        }
        .container {
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        input, textarea {
            width: 100%;
            padding: 10px;
            margin: 10px 0;
            border-radius: 4px;
            border: 1px solid #ccc;
        }
        button {
            padding: 10px 20px;
            background-color: #5cb85c;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            display: block;
            margin: 20px auto;  /* This centers the button */
            width: 150px;       /* You can adjust the width as needed */
            text-align: center; /* Ensures the text inside the button is centered */
        }
        .footer {
            margin-top: 20px;
            text-align: center;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Contact Us</h1>
        <form id="contact-form">
            <input type="text" id="name" placeholder="Your Name" required>
            <input type="email" id="email" placeholder="Your Email" required>
            <textarea id="message" placeholder="Your Message" required></textarea>
            <button type="submit">Submit</button>
        </form>
        <p id="response-message"></p>

        <div class="footer">
            <p>Created by <a href="https://github.com/swapnilyavalkar" target="_blank">Swapnil Yavalkar</a></p>
            <p>Hosted On Server: <span id="hostname"></span></p>
        </div>
    </div>

    <script>
        async function submitForm(event) {
            event.preventDefault();

            const formData = {
                name: document.getElementById('name').value,
                email: document.getElementById('email').value,
                message: document.getElementById('message').value
            };

            const response = await fetch('<API_Gateway_Invoke_URL>/submitForm', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(formData)
            });

            const result = await response.json();
            document.getElementById('response-message').textContent = result.message;
        }

        document.getElementById('contact-form').addEventListener('submit', submitForm);

        // Display hostname
        document.getElementById('hostname').textContent = window.location.hostname;
    </script>
</body>
</html>

```

#### 1.2 **Dockerfile - `Dockerfile`**
This Dockerfile will containerize the application. [Sample file](https://github.com/swapnilyavalkar/aws-lambda-contact-form/blob/main/Dockerfile) 

```Dockerfile
# Use a basic node image
FROM node:18-alpine

# Set working directory
WORKDIR /usr/src/app

# Copy app files
COPY . .

# Install dependencies (if any)
RUN npm install

# Expose port 3000 for the web app
EXPOSE 3000

# Command to run the app
CMD ["npx", "http-server", "-p", "3000"]
```

#### 1.3 **`package.json`**
Since this is a simple static web app, we use `http-server` to serve the static files. [Sample file](https://github.com/swapnilyavalkar/aws-lambda-contact-form/blob/main/package.json)

```json
{
  "name": "contact-form-app",
  "version": "1.0.0",
  "scripts": {
    "start": "http-server -p 3000"
  },
  "dependencies": {
    "http-server": "^14.0.0"
  }
}
```

#### 1.4 **Create SNS Topic with Email subscription**

---

### **Step 2: Create and Configure the Lambda Function**

You will now create an AWS Lambda function to process form data submissions and send notifications via SNS.

#### 2.1 **Add Lambda Function Code**:
1. Create a new directory for your Lambda function:
   
        ```bash
        mkdir my-lambda-function
        cd my-lambda-function
        ```
3. Create a file `index.js` with (code)[]:

4. Install the `aws-sdk` in your directory:
   
     ```bash
     npm init -y  # Initializes a new Node.js project with a package.json file
     npm install aws-sdk
     ```

     ```javascript
        const AWS = require('aws-sdk');
        const sns = new AWS.SNS();
        exports.handler = async (event) => {
          const { name, email, message } = JSON.parse(event.body);
      
          const snsParams = {
              Message: `New contact form submission:\nName: ${name}\nEmail: ${email}\nMessage: ${message}`,
              Subject: 'Contact Form Submission',
              TopicArn: 'arn:aws:sns:ap-south-1:307946656533:MyTopic'  // Replace with actual SNS Topic ARN
          };
      
          try {
              await sns.publish(snsParams).promise();
              return {
                  statusCode: 200,
                  body: JSON.stringify({ message: 'Form submitted successfully!' })
              };
          } catch (error) {
              return {
                  statusCode: 500,
                  body: JSON.stringify({ message: 'Failed to submit form.', error })
              };
          }
      };
     
     ```
5. Zip the contents of the directory, including the `node_modules` directory and the `index.js` file. [Sample Zip File](https://github.com/swapnilyavalkar/aws-lambda-contact-form/blob/main/lambda-function-1.zip)
   
     ```bash
     zip -r lambda-function.zip .
     ```
6. Create a Author from scratch lambda funtion with runtime Node.js 18.x and Use an execution role with permissions for Lambda, SNS, and CloudWatch Logs.
7. Choose your Lambda function.
   - Under the **Code** section, select **Upload from** > **.zip file** and upload the `lambda-function.zip`.

8. **Test the Function**:
   - Test the function again from the Lambda console or through an event trigger.
     
     ```json
     # Sample data
     {
        "body": "{\"name\":\"John Doe\",\"email\":\"johndoe@example.com\",\"message\":\"This is a test message.\"}"
     }
     ```
---

### **Step 3: Set Up API Gateway to Trigger Lambda**

1. Navigate to the **API Gateway** console.
2. **Create a new API**:
   - Choose **HTTP API**.
   - Name it `ContactFormAPI`.
3.**Integrate the route with your Lambda function** (`ContactFormHandler`).
4. **Create a POST route** with the path `/submitForm`.
5. Deploy the API and note the **Invoke URL**.

---

### **Step 4: Modify and Deploy the Web App**

#### 4.1 **Modify the Web App to Call API Gateway**:
- In [index.html](https://github.com/swapnilyavalkar/aws-lambda-contact-form/blob/main/index.html), mention your `'<https://04i60b2tle.execute-api.ap-south-1.amazonaws.com/MyDeployStage/submitForm>'` with your API Gateway’s invoke URL as shown below.

   ```javascript
   const response = await fetch('https://04i60b2tle.execute-api.ap-south-1.amazonaws.com/MyDeployStage/submitForm', {
                   method: 'POST',
                   headers: {
                       'Content-Type': 'application/json'
                   },
                   body: JSON.stringify(formData)
               });
   ```
  

#### 4.2 **Build and Push the Docker Image**:
1. **Create your ECR**:
2. **Build the Docker image**:
   
   ```bash
   cd aws-lambda-contact-form
   docker build -t contact-form-app .
   ```

4. **Tag the Docker image**:
   
   ```bash
   docker tag contact-form-app:latest <account_id>.dkr.ecr.<region>.amazonaws.com/contact-form-app:latest
   ```

5. **Push the image to ECR**:
   
   ```bash
   docker push <account_id>.dkr.ecr.<region>.amazonaws.com/contact-form-app:latest
   ```

---

### **Step 5: Deploy the Web Application on ECS**

1. **Create an ECS Cluster**:
   - Navigate to the **ECS** console.
   - Create a **Fargate Cluster**.

2. **Create a Task Definition**:
   - Choose **Fargate**.
   - Add the container definition using the image from ECR.
   - Set the container port to **3000**.

3. **Create a Service**:
   - Deploy the service in the VPC and subnets.
   - Ensure **Auto-assign public IP** is enabled for public access.

4. **Configure Security Groups**:
   - Allow inbound HTTP traffic on port **3000**.

---

### **Step 6: Test the Application**

1. **Access the Application**:
   - Use the **public IP** of the ECS service to access the app in the browser.
   
2. **Submit the Form**:
   - Test the contact form by submitting it with sample data.
   - Ensure the data is correctly passed to the Lambda function, and you receive the response.
   - If you get any CORS error in browser after submitting the request then use below curl command to send the request. Modify URL as per your API endpoint.

      ```bash

      curl -X POST https://w8kuys4658.execute-api.ap-south-1.amazonaws.com/dev/submitForm \
      -H "Content-Type: application/json" \
      -d '{"name": "John Doe", "email": "john@example.com", "message": "This is a test message"}'
      
      ```   
     
   - You will also receive email notification using SNS Topic.

      ![email](https://github.com/user-attachments/assets/8dbf0d33-51b0-4cd3-be2c-88ab75988a00)

---

### **Step 7: Clean Up (Optional)**

After testing, clean up resources to avoid unwanted charges:
- Delete the ECS service, cluster, and ECR images.
- Remove the Lambda function, SNS Topic, Subscription, ECS namespace from AWS Cloud Map and API Gateway routes.
