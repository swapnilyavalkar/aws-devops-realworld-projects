# First Stage: Build
FROM golang:1.18 AS builder

# Set Working directory
WORKDIR /app

# Copy go module files and download dependencies
COPY go.mod go.sum ./
RUN go mod download

# Copy the rest of the application code
COPY . .

# Build the go application
RUN go build -o main .

# Second Stage: Production
FROM scratch

# Copy the go binary from builder stage
COPY --from=builder /app/main /main

# Expose Port
EXPOSE 8080

# Run the application
ENTRYPOINT [ "/main" ]



