# **5. Go Application with Multi-Stage Build**

- **Objective**: Use a multi-stage build to create a lightweight Go application image.
- **Skills Covered**: Multi-stage builds, using scratch images.
- **Dependency**: Ensure to install [go](https://go.dev/dl/) locally on your system.

## **Project Steps**

   1. **Create a Go App (`main.go`)**:

      ```go
      package main

      import (
          "fmt"
          "net/http"
      )

      func handler(w http.ResponseWriter, r *http.Request) {
          fmt.Fprintf(w, "Hello from Go in Docker!")
      }

      func main() {
          http.HandleFunc("/", handler)
          http.ListenAndServe(":8080", nil)
      }
      ```

   2. **Write the Dockerfile**:

      ```dockerfile
      # First Stage: Build
      FROM golang:1.18 AS builder

      # Set working directory
      WORKDIR /app

      # Copy source code
      COPY . .

      # Build the Go application
      RUN go build -o main .

      # Second Stage: Production
      FROM scratch

      # Copy the Go binary from the builder stage
      COPY --from=builder /app/main /main

      # Expose port
      EXPOSE 8080

      # Run the application
      ENTRYPOINT ["/main"]
      ```

   3. **Build and run the image**:

      ```bash
      docker build -t go-app .
      docker run -d -p 8080:8080 go-app
      ```

- **Outcome**: Access `http://localhost:8080` to see "Hello from Go in Docker!".