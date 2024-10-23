# First Stage: Build
FROM node:16 AS builder

# set the working directory
WORKDIR /app

# install dependencies
COPY package*.json ./
RUN npm install

# Copy source code
COPY . .

# Second Stage: Production
FROM node:16-slim

# Set working directory
WORKDIR /app

# Copy only the necessary files from builder
COPY --from=builder /app .

# Expose port
EXPOSE 3000

# Run the application
CMD [ "node", "app.js" ]



