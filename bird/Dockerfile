# syntax=docker/dockerfile:1
FROM golang:1.22-alpine AS builder

# Set the working directory
WORKDIR /app

# Copy go.mod and go.sum files
COPY go.mod ./

# Download dependencies
RUN go mod download

# Copy the rest of the application code
COPY . .

# Build the bird API
RUN go build -o bird-api .

# Use the latest minimal Alpine image for the final deployment
FROM alpine:latest

WORKDIR /root/
COPY --from=builder /app/bird-api .
CMD ["./bird-api"]
EXPOSE 4201
