# Start from the official Go image
FROM golang:1.21-alpine AS builder

# Set the working directory inside the container
WORKDIR /app

# Copy the source code into the container
COPY . .

# Create a go.mod file if it doesn't exist and set the correct Go version
RUN go mod init main || true
RUN go mod edit -go=1.20

# Tidy and download dependencies
RUN go mod tidy

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -o main .

# Start a new stage from scratch
FROM alpine:latest  

# Set the working directory
WORKDIR /root/

# Copy the binary from builder
COPY --from=builder /app/main .

# Expose the port the app runs on
EXPOSE 8080

# Command to run the executable
ENTRYPOINT ["./main"]
