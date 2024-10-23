# **6. React Frontend with NGINX**

- **Objective**: Build and serve a React frontend using NGINX.
- **Skills Covered**: Multi-stage build, using build artifacts in the final image.

## **Project Steps**

   1. **Create a basic React App**:

      ```bash
      npx create-react-app my-react-app
      cd my-react-app
      ```

   2. **Write the Dockerfile**:

      ```dockerfile
      # First Stage: Build React App
      FROM node:16 AS builder

      # Set working directory
      WORKDIR /app

      # Copy package files and install dependencies
      COPY package*.json ./
      RUN npm install

      # Copy source code and build it
      COPY . .
      RUN npm run build

      # Second Stage: Serve with NGINX
      FROM nginx:alpine

      # Copy built files to NGINX html directory
      COPY --from=builder /app/build /usr/share/nginx/html

      # Expose port 80
      EXPOSE 80

      # Run NGINX
      CMD ["nginx", "-g", "daemon off;"]
      ```

   3. **Build and run the container**:

      ```bash
      docker build -t react-app .
      docker run -d -p 3000:80 react-app
      ```

- **Outcome**: Visit `http://localhost:3000` to see the React app served by NGINX.

---
