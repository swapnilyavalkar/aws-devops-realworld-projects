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

# Remove default NGINX HTML files
RUN rm -rf /usr/share/nginx/html/*

# Copy buil files to NGINX html directory
COPY --from=builder /app/build /usr/share/nginx/html

# Expose port
EXPOSE 80

# Run NGINX
CMD ["nginx", "-g", "daemon off;"]