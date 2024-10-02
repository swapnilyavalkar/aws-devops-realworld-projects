# 01-cloudfront-s3-static-websites

## Objective:
Host your application’s static content (e.g., HTML, CSS, JavaScript, images) on Amazon S3 and use Amazon CloudFront as a Content Delivery Network (CDN) to deliver the content globally with low latency.

---

## Step 1: Create an S3 Bucket for Static Content

### Why are we doing this?
Amazon S3 provides scalable object storage, which is ideal for hosting static files. By offloading these files to S3, we reduce the load on our web server, allowing it to focus on dynamic content. S3 is also optimized for low-cost, high-availability storage.

### Instructions:
1. **Go to S3:**
   - Log in to the AWS Management Console and navigate to S3.

2. **Create an S3 Bucket:**
   - Click `Create Bucket`.
   - Enter a bucket name (e.g., `my-app-static-content`).
   - Select your AWS region (e.g., `ap-south-1`).
   - Uncheck `Block All Public Access` (since this bucket will serve public static content).
   - Click `Create Bucket`.

3. **Upload Static Content to S3:**
   - Click on your newly created bucket.
   - Click `Upload` and upload all static files (e.g., HTML, CSS, JavaScript, images) from your application that do not require server-side processing.

4. **Configure Bucket Permissions for Public Access:**
   - Go to the `Permissions` tab of the bucket, and under `Bucket Policy`, add the following policy to allow public read access:

   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Effect": "Allow",
         "Principal": "*",
         "Action": "s3:GetObject",
         "Resource": "arn:aws:s3:::my-app-static-content/*"
       }
     ]
   }
   ```

   - Replace `my-app-static-content` with your actual bucket name.
   - Save the policy.

---

## Step 2: Set Up CloudFront for CDN

### Why are we doing this?
Amazon CloudFront helps in delivering static content with low latency across the globe by caching the content in edge locations. This enhances the performance and reduces the load on S3 by serving cached versions.

1. **Go to CloudFront:**
   - In the AWS Management Console, navigate to CloudFront under the Services menu.

2. **Create a CloudFront Distribution:**
   - Click `Create Distribution` and select `Web`.
   - In the `Origin Domain Name`, enter the S3 bucket’s URL (for example, `my-app-static-content.s3.amazonaws.com`).
   - For `Viewer Protocol Policy`, select `Redirect HTTP to HTTPS` to ensure secure content delivery.
   - In `Allowed HTTP Methods`, select `GET, HEAD` since we're only serving static files.
   - Leave other settings as default and click `Create Distribution`.

3. **Get the CloudFront Distribution Domain Name:**
   - After the distribution is created, CloudFront will provide a Domain Name (e.g., `d12345abcdef.cloudfront.net`).
   - This domain will act as the CDN URL for serving your static content.

---

## Step 3: Modify Your Application to Serve Static Content from S3/CloudFront

### Why are we doing this?
By serving static content from S3 and CloudFront, we ensure faster load times and improve performance. This reduces the number of requests going to the main server and leverages the CDN to distribute the content efficiently.

1. **Update Static Content URLs:**
   - Modify your web application’s HTML, CSS, or JavaScript files to point to the CloudFront distribution domain instead of serving static content from your EC2 instance.

   **Example before:**
   ```html
   <img src="/images/logo.png" alt="My Logo">
   ```

   **Example after:**
   ```html
   <img src="https://d12345abcdef.cloudfront.net/images/logo.png" alt="My Logo">
   ```

   - Replace `d12345abcdef.cloudfront.net` with your actual CloudFront domain name.

2. **Test the Application:**
   - Deploy the updated version of your application.
   - Test the application in the browser and check if static content is being served from CloudFront. Use the Network tab in the browser developer tools to ensure that the static content requests are pointing to the CloudFront URL.

---

## Step 4: Optional - Set Up Caching and Performance Optimization

### Why are we doing this?
Optimizing caching behavior ensures that content is delivered more efficiently, reducing the load on S3 and minimizing latency for users. Enabling compression also helps in reducing the size of assets, further improving performance.

### Instructions:
1. **Configure Cache Behavior in CloudFront:**
   - Go back to your CloudFront Distribution.
   - Click `Behaviors` and select the default behavior.
   - Modify the Caching settings to control how long objects are cached in CloudFront edge locations. For static content like images and CSS, set a longer caching period.

2. **Enable Gzip Compression:**
   - In the CloudFront distribution settings, enable Gzip compression to reduce the size of your text-based assets like HTML, CSS, and JavaScript files.

---

## Step 5: Automate S3 and CloudFront Deployment in Jenkins

### Why are we doing this?
Automating the deployment of static content ensures consistency and reduces manual errors. By invalidating the CloudFront cache after updates, we make sure that users always get the most up-to-date content.

### Instructions:
1. **Install AWS CLI on Jenkins EC2 Instance:**
   ```bash
   sudo apt-get install awscli -y
   ```

2. **Update Jenkinsfile for Static Content Deployment:**
   Add a new stage in your Jenkinsfile to upload static content to S3 and invalidate CloudFront:

   ```groovy
   pipeline {
       agent any
       stages {
           stage('Upload Static Content to S3') {
               steps {
                   script {
                       sh '''
                       aws s3 sync /path/to/static/files s3://my-app-static-content
                       '''
                   }
               }
           }
           stage('Invalidate CloudFront Cache') {
               steps {
                   script {
                       sh '''
                       aws cloudfront create-invalidation --distribution-id E1234567890 --paths "/*"
                       '''
                   }
               }
           }
       }
   }
   ```

3. **Test the Automated Pipeline:**
   - Make a change to your static content and push it to the GitHub repository.
   - Jenkins will automatically upload the new static content to S3 and invalidate the CloudFront cache.