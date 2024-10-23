# Docker File

## **What is a Dockerfile?**

A **Dockerfile** is a text file that contains instructions for building a Docker image. It defines the OS, software, dependencies, and commands that make up a Docker container.

## **Dockerfile Skeleton**

Here is a basic skeleton of a Dockerfile, along with explanations for each instruction:

```dockerfile
# Base image to start building from
FROM <base_image>

# Maintainer information
LABEL maintainer="<name@example.com>"

# Set environment variables
ENV <key>=<value>

# Copy files from local to the container
COPY <src_path> <dest_path>

# Add files from local or URL to the container
ADD <src_path> <dest_path>

# Install dependencies and run commands
RUN <command_to_run>

# Set working directory
WORKDIR <directory_path>

# Expose port for the container
EXPOSE <port_number>

# Specify the default command to run
CMD ["<command>", "<arg1>", "<arg2>"]

# Alternative entry point command
ENTRYPOINT ["<command>", "<arg1>", "<arg2>"]
```

## **Detailed Explanation of Dockerfile Instructions**

### 1. **FROM**

- Sets the **base image** for your Docker image.
- This is the first instruction in every Dockerfile.
- It can be a public image (e.g., `ubuntu`, `nginx`, etc.) or your own image from a Docker registry.
- **Syntax**: `FROM <base_image>:<tag>`.
- **Example**:

     ```dockerfile
     FROM nginx:latest
     ```

- It uses the official NGINX image as the base to build on.

### 2. **LABEL**

- Adds metadata to your image, like maintainer info, version, description, etc.
- **Syntax**: `LABEL <key>=<value>`.
- **Example**:

     ```dockerfile
     LABEL maintainer="yourname@example.com"
     ```

- Helps document the image’s details.

### 3. **ENV**

- Sets environment variables inside the container.
- Useful for setting configuration values.
- **Syntax**: `ENV <key> <value>`.
- **Example**:

     ```dockerfile
     ENV NODE_ENV=production
     ```

- Sets the `NODE_ENV` variable to `production`.

### 4. **COPY**

- Copies files or directories from the local file system to the container.
- **Syntax**: `COPY <src_path> <dest_path>`.
- **Example**:

     ```dockerfile
     COPY ./app /usr/src/app
     ```

- Copies the `app` directory to `/usr/src/app` in the container.

### 5. **ADD**

- Similar to `COPY`, but also supports extracting compressed files and downloading from URLs.
- **Syntax**: `ADD <src_path> <dest_path>`.
- **Example**:

     ```dockerfile
     ADD https://example.com/file.tar.gz /app
     ```

- Adds files from a URL or extracts compressed files into the container.

### 6. **RUN**

- Executes commands in a new layer of the image.
- Used to install software, update packages, or set up configurations.
- **Syntax**: `RUN <command>`.
- **Example**:

     ```dockerfile
     RUN apt-get update && apt-get install -y nginx
     ```

- Installs NGINX using the apt package manager.

### 7. **WORKDIR**

- Sets the **working directory** inside the container.
- All subsequent instructions will be run from this directory.
- **Syntax**: `WORKDIR <directory_path>`.
- **Example**:

     ```dockerfile
     WORKDIR /usr/src/app
     ```

- Changes the working directory to `/usr/src/app`.

### 8. **EXPOSE**

- Informs Docker that the container listens on a specified network port at runtime.
- **Syntax**: `EXPOSE <port_number>`.
- **Example**:

     ```dockerfile
     EXPOSE 80
     ```

- Specifies that the container listens on port 80.

### 9. **CMD**

- Sets the default command that runs when the container starts.
- Typically used for the main application.
- **Syntax**: `CMD ["<command>", "<arg1>", "<arg2>"]`.
- **Example**:

     ```dockerfile
     CMD ["nginx", "-g", "daemon off;"]
     ```

- Starts NGINX in the foreground.

### 10. **ENTRYPOINT**

- Similar to `CMD`, but it **cannot be overridden** by the command-line arguments when starting a container.
- Sets up the base command for the container.
- **Syntax**: `ENTRYPOINT ["<command>", "<arg1>"]`.
- **Example**:

     ```dockerfile
     ENTRYPOINT ["python3", "app.py"]
     ```

- Starts the Python script `app.py`.

## **Dockerfile Example**

Let's look at a complete example of a Dockerfile to build a basic NGINX-based image that serves static content:

```dockerfile
# Start from the official NGINX base image
FROM nginx:latest

# Add metadata to the image
LABEL maintainer="yourname@example.com"

# Set environment variable
ENV NGINX_VERSION=1.21.6

# Copy website files to the container
COPY ./index.html /usr/share/nginx/html/index.html

# Expose port 80
EXPOSE 80

# Define the default command to run NGINX
CMD ["nginx", "-g", "daemon off;"]
```

## **Explanation of the Example Dockerfile**

1. **FROM nginx:latest**: Uses the official NGINX image as the base.
2. **LABEL maintainer="<yourname@example.com>"**: Adds metadata indicating the maintainer.
3. **ENV NGINX_VERSION=1.21.6**: Sets an environment variable `NGINX_VERSION` inside the container.
4. **COPY ./index.html /usr/share/nginx/html/index.html**: Copies a local HTML file into the NGINX HTML directory.
5. **EXPOSE 80**: Specifies that the container listens on port 80.
6. **CMD ["nginx", "-g", "daemon off;"]**: Runs NGINX in the foreground as the default command.

## **Building and Running Docker Images**

1. **Build the Docker Image**:

   ```bash
   docker build -t my-nginx-image .
   ```

   - **-t**: Tags the image with a name (`my-nginx-image`).
   - **.**: Indicates the current directory where the Dockerfile is located.

2. **Run the Docker Container**:

   ```bash
   docker run -d -p 8080:80 my-nginx-image
   ```

   - **-d**: Runs the container in detached mode.
   - **-p 8080:80**: Maps port 8080 on your local machine to port 80 in the container.

## **Best Practices for Writing Dockerfiles**

1. **Use Official Base Images**: Start from official or trusted base images for better security.
2. **Minimize Layers**: Combine commands using `&&` in `RUN` to reduce image layers.
   - Example:

     ```dockerfile
     RUN apt-get update && apt-get install -y nginx
     ```

3. **Use `.dockerignore`**: Add a `.dockerignore` file to exclude unnecessary files from the image build.
   - Example `.dockerignore`:

     ```
     node_modules
     *.log
     ```

4. **Set Proper Work Directory**: Use `WORKDIR` to organize file paths inside the container.
5. **Use Specific Tags**: Use specific image tags (e.g., `nginx:1.21`) instead of `latest` to ensure consistency.
6. **Use Multi-Stage Builds**: Optimize images by using multi-stage builds to create lightweight production images.

---

By understanding these concepts and features, you can create efficient, clean, and maintainable Dockerfiles that form the foundation of containerized applications. This step-by-step explanation should help you write and optimize Dockerfiles effectively.

**Multi-stage builds** in Docker are an advanced technique to create optimized, lightweight images by separating the build and runtime environments. This approach allows you to **build your application in one stage** and **copy only the necessary artifacts to the final image**. This results in a **smaller, more secure, and production-ready image**.

## **Why Use Multi-Stage Builds?**

1. **Smaller Images**: By only copying the final executable or required files to the final image, you significantly reduce the size.
2. **Better Security**: The final image contains only what’s needed to run the application, without unnecessary tools or dependencies (e.g., compilers, build tools).
3. **Cleaner Layers**: It keeps your image layers minimal, leading to faster image pulls and reduced attack surface.
4. **Simplified Dockerfiles**: Allows you to separate the build logic from the runtime, making Dockerfiles easier to read and maintain.

## **How Multi-Stage Builds Work**

A multi-stage build uses **multiple `FROM` statements** in the Dockerfile. Each `FROM` statement starts a new build stage, and you can **copy artifacts from one stage to another** using the `COPY --from=<stage_name> <src> <dest>` instruction.

## **Multi-Stage Build Example**

Let’s see an example using a Node.js application where we build the app in one stage and create a lightweight runtime image in another.

### **Dockerfile with Multi-Stage Build**

```dockerfile
# First Stage: Build
FROM node:16 AS builder

# Set working directory
WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install

# Copy the rest of the application code
COPY . .

# Build the application
RUN npm run build

# Second Stage: Production Image
FROM nginx:alpine

# Copy built files from the previous stage to Nginx directory
COPY --from=builder /app/build /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
```

## **Explanation of the Example**

1. **First Stage: Build Stage**
   - **`FROM node:16 AS builder`**: Uses the Node.js 16 image as the base and labels this stage as `builder`.
   - **`WORKDIR /app`**: Sets the working directory to `/app`.
   - **`COPY package*.json ./`**: Copies the package files for dependency installation.
   - **`RUN npm install`**: Installs all the dependencies in the image.
   - **`COPY . .`**: Copies the entire application code to the `/app` directory.
   - **`RUN npm run build`**: Executes the build command to create the production-ready build (e.g., optimized JavaScript/CSS files).

2. **Second Stage: Production Image**
   - **`FROM nginx:alpine`**: Uses a lightweight Alpine-based NGINX image.
   - **`COPY --from=builder /app/build /usr/share/nginx/html`**: Copies only the built files from the first stage (`builder`) to the NGINX directory for serving static content.
   - **`EXPOSE 80`**: Exposes port 80 for the NGINX web server.
   - **`CMD ["nginx", "-g", "daemon off;"]`**: Runs NGINX as the main process.

## **Benefits of the Multi-Stage Build Example**

- **Smaller Final Image**: The final image is based on `nginx:alpine`, which is much smaller than the original Node.js image, as it only contains the built application files.
- **No Build Tools in Production**: The final image does not include the Node.js runtime or other build tools, making it more secure and efficient.
- **Faster Deployments**: The smaller image size speeds up deployments, as fewer layers need to be transferred.

## **Another Example: Multi-Stage Build with Go Application**

Let’s take a Go application as another example where we compile the Go binary in the first stage and create a minimal runtime image in the second stage.

### **Dockerfile with Go Multi-Stage Build**

```dockerfile
# First Stage: Build
FROM golang:1.18 AS builder

# Set the working directory
WORKDIR /app

# Copy the Go module files and download dependencies
COPY go.mod go.sum ./
RUN go mod download

# Copy the rest of the application code
COPY . .

# Build the Go application
RUN go build -o main .

# Second Stage: Production Image
FROM scratch

# Copy the compiled binary from the builder stage
COPY --from=builder /app/main /main

# Set the entrypoint to run the application
ENTRYPOINT ["/main"]
```

## **Explanation of the Go Example**

- **First Stage (Build)**:
  - Uses `golang:1.18` as the base image and compiles the Go application.
- **Second Stage (Production)**:
  - Uses the `scratch` image, which is an **empty base image**, making the final image extremely small.
  - Only the compiled binary is copied from the build stage, resulting in a **minimal production-ready container**.

## **Summary of Multi-Stage Builds**

- **Use multi-stage builds to create images that are optimized for production.**
- **Build tools and dependencies are separated from the final runtime image.**
- **The final image only contains necessary files, reducing size and security risks.**

This is a powerful technique to **improve the efficiency, security, and performance** of Docker containers, making them ready for production deployment.

### **Advanced Concepts and Best Practices for Dockerfiles**

1. **Multi-Stage Builds (In-Depth)**
   - While you have already learned about **multi-stage builds**, you can explore how to use multiple stages for building, testing, and optimizing images in complex projects.
   - **Example**: You can add separate stages for **unit testing**, **code linting**, and then final packaging, making the CI/CD process more efficient.

2. **Caching for Faster Builds**
   - Docker utilizes a **layered build cache**, meaning it caches each command layer during the build process. Understanding how to write Dockerfiles to **leverage caching** can significantly improve build speeds.
   - **Best Practice**: Place commands that change less frequently (like installing dependencies) earlier in the Dockerfile, and commands that change frequently (like copying code) later.

3. **Onbuild Triggers**
   - `ONBUILD` triggers allow you to specify instructions that run automatically when an image is used as a base for another build.
   - **Example**:

     ```dockerfile
     FROM node:16
     ONBUILD COPY . /app
     ```

   - This can be useful for creating **base images** for internal teams to use consistently.

4. **Health Checks**
   - Use the `HEALTHCHECK` instruction to define how Docker should check whether your container is still running as expected.
   - **Example**:

     ```dockerfile
     HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
       CMD curl -f http://localhost/ || exit 1
     ```

   - This ensures that your container is monitored for health and can automatically restart if it becomes unhealthy.

5. **User Permissions and Security**
   - By default, Docker containers run as **root**, which can be a security risk. It’s a good practice to create a **non-root user** to run the application.
   - **Example**:

     ```dockerfile
     RUN addgroup -S appgroup && adduser -S appuser -G appgroup
     USER appuser
     ```

   - This makes the container more secure by minimizing the risk of privilege escalation.

6. **Using `.dockerignore` Files**
   - The `.dockerignore` file works similarly to `.gitignore`, excluding files from the build context to reduce the build size and time.
   - **Example `.dockerignore`**:

     ```
     node_modules
     .git
     *.log
     ```

   - This improves efficiency by copying only the necessary files into the build context.

7. **ARG vs. ENV**
   - Understand the difference between `ARG` and `ENV`:
     - **`ARG`** is for build-time variables (used during the build process).
     - **`ENV`** is for runtime environment variables (set inside the running container).
   - **Example**:

     ```dockerfile
     ARG NODE_VERSION=16
     FROM node:$NODE_VERSION
     ```

8. **Volume Management**
   - Use the `VOLUME` instruction to specify which directories should be treated as volumes (persistent storage).
   - **Example**:

     ```dockerfile
     VOLUME ["/data"]
     ```

   - This helps in separating data from the container’s file system and ensuring data persistence.

9. **Optimizing Image Size**
   - Use **alpine-based images** or minimal base images (e.g., `nginx:alpine`, `python:3.9-slim`) to reduce image size.
   - Use multi-stage builds to eliminate unnecessary files or dependencies from the final image.

10. **Entrypoint vs. CMD (Deep Dive)**
    - Understanding when to use `ENTRYPOINT` vs. `CMD` is crucial.
      - **`ENTRYPOINT`**: Sets a fixed command that cannot be overridden at runtime.
      - **`CMD`**: Sets the default command but can be overridden.
    - They can also be combined to pass arguments:

      ```dockerfile
      ENTRYPOINT ["python"]
      CMD ["app.py"]
      ```

    - Here, you can override `app.py` with a different file when running the container.

11. **Labeling for Metadata**
    - Use the `LABEL` instruction for better documentation, tracing, and organization of your images.
    - **Example**:

      ```dockerfile
      LABEL version="1.0" maintainer="yourname@example.com" description="React App"
      ```

12. **Handling Signals Gracefully**
    - Ensure your container handles **signals gracefully**, allowing for clean shutdowns.
    - Using `ENTRYPOINT` with shell command handling can help:

      ```dockerfile
      ENTRYPOINT ["bash", "-c", "trap 'echo signal received' SIGTERM; sleep infinity"]
      ```

### **Additional Tools and Techniques**

1. **Dive**: Use a tool like [**Dive**](https://github.com/wagoodman/dive) to analyze Docker images for size and efficiency, helping to identify large layers that can be optimized.
2. **Linting**: Use Dockerfile linting tools like [**hadolint**](https://github.com/hadolint/hadolint) to check for best practices, security issues, and optimization tips.
3. **Docker Compose**: Learning how Dockerfiles interact with **Docker Compose** for multi-container applications is crucial in building more complex, orchestrated setups.
4. **Custom Base Images**: Create your own custom base images tailored to your environment, reducing build times and maintaining consistency across projects.

# **01-Project**

-

## **1. Static Website with NGINX**

- **Objective**: Create a Docker image for a simple static website using NGINX.
- **Skills Covered**: Base images, COPY, WORKDIR, EXPOSE, CMD.

### **Project Steps**

   1. **Create an `index.html` file**:

      ```html
      <html>
        <head><title>Welcome to Docker!</title></head>
        <body><h1>Hello from Docker!</h1></body>
      </html>
      ```

   2. **Write the Dockerfile**:

      ```dockerfile
      # Use NGINX base image
      FROM nginx:alpine

      # Copy the website files to the container
      COPY ./index.html /usr/share/nginx/html/index.html

      # Expose port 80
      EXPOSE 80

      # Run NGINX
      CMD ["nginx", "-g", "daemon off;"]
      ```

   3. **Build and run the image**:

      ```bash
      docker build -t static-website .
      docker run -d -p 8080:80 static-website
      ```

- **Outcome**: You should see "Hello from Docker!" when you access `http://localhost:8080` in your browser.
