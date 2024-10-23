# **2. Node.js Application with Multi-stage builds**

- **Objective**: Dockerize a simple Node.js application.
- **Skills Covered**: Multi-stage builds, using environment variables, EXPOSE, WORKDIR.

## **Project Steps**

   1. **Create a Node.js App (`app.js`)**:

      ```javascript
      const express = require('express');
      const app = express();
      const port = process.env.PORT || 3000;

      app.get('/', (req, res) => {
        res.send('Hello from Node.js in Docker!');
      });

      app.listen(port, () => {
        console.log(`Server running on port ${port}`);
      });
      ```

   2. **Create a `package.json`**:

      ```json
      {
        "name": "node-docker",
        "version": "1.0.0",
        "main": "app.js",
        "dependencies": {
          "express": "^4.17.1"
        }
      }
      ```

   3. **Write the Dockerfile**:

      ```dockerfile
      # First Stage: Build
      FROM node:16 AS builder

      # Set working directory
      WORKDIR /app

      # Install dependencies
      COPY package*.json ./
      RUN npm install

      # Copy source code
      COPY . .

      # Second Stage: Production
      FROM node:16-slim

      # Set working directory
      WORKDIR /app

      # Copy only the necessary files from the builder
      COPY --from=builder /app .

      # Expose port
      EXPOSE 3000

      # Run the application
      CMD ["node", "app.js"]
      ```

   4. **Build and run the container**:

      ```bash
      docker build -t node-app .
      docker run -d -p 3000:3000 node-app
      ```

- **Outcome**: Visit `http://localhost:3000` to see "Hello from Node.js in Docker!".
