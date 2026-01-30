# syntax=docker/dockerfile:1
FROM golang:1.21-alpine AS builder

WORKDIR /app
COPY main.go .

RUN go build -o bird-frontend main.go

FROM alpine:latest

WORKDIR /root/
COPY --from=builder /app/bird-frontend .
CMD ["./bird-frontend"]
EXPOSE 3000