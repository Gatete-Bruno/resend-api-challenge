# Bird API - Highly Available Infrastructure on AWS

Production-grade API infrastructure deployed on AWS EKS with auto-scaling, CloudFront CDN, and comprehensive monitoring. Now includes a fullscreen bird image viewer frontend.

## System Architecture Visualization

[System Architecture Diagram](https://mermaid.live/view#pako:eNqtWP2O2jgQfxUrVU97usASh7CATpVC2I-qXYQK7Uq9vT9MYiBHiJGTdJfrVrpnuUe7J7mxnU8IC9sWhLHn4-fxZDwz8FVzmUe1vrbgZLNE08F9iOAVJTNFsO8mf9xrMCInYImHzpKoQUkUN4xf77U_lXBF4QNLYmqZoCRnyDLR2XXAZiRAw9GkqiReQARZGNEHGrEgiX0W_j7j52-uKWtwgPDDBfoN3VASxEvkLKm7iiogNPSKRY1B0u4rzsIY9ikWyBmO9owBmjDGj2LuzwpTrMbaD5FD3CWVa88IYvZl-RdzLzobt-kK0LkAbYY0fpFxn8YObAgjOjNaTfk-Nzr7XsoVxsks8N1JMoOdIlBVa5QS9vTEa2RPQRBGdE1i-kC28gyXC06jCE05mc99d0-xYnjV-Ko93P8CqCWDFCGzCJ3dJkHsN-zPv9YaVwTaZwO08-gitdLyOBCvQlR8I0OeJcbNNfX8ZC1XuGEhTjfgFhKhm7F9EGnMPEO4H777aOZzryEfojj6cyp2RYVs_GelBxVpf00W9KDOntP3Hb_jM1z22exZn-HMZ_gHfYZf7jP8Ip_hH_LZqZH7nhFvQAISupSLwB3R-IHxlaSjnFF_o94PRIKDL2RK940Zj5HZarXk6rhbQNNIAYwCoI1bRgFw6MCghFNdXNEtbX7YZad65_KdSMswIgfOwVmAxuARWmuRPX4Lsu-SGeVw5WkkCNKWT-BAyKHIaOJereYEMqqXBJSDfj6vlUytUKLFAt2SEI5arwNxDMIwlrSlXRet18gZf0RTwhc7CTvfz5bVIoli2MROYha5JFO_hWKAddj6EVkohCsVfbebb1nox4xDjYPtigX6BcJwsYBZvXF3WSm7I7G7VEZRqFluBKUSNCN1zIZHtlBWIQxFKat_dgHhaxH-bVQAplQJ8t8__4o7Kf114y-WFeItXTO-rdJljhmx-AMl3rYiDQU-JhxqgpD_bpdNwEXwyEXEqFl9ZIkLOjHRIHFXNJZmTCmHYsf4GiCgQklaqR8QbquFGg5FPhpuQ7Jmw4FUkwCg4a7qHlHlJPkin-x0WJePEGIhCcR1S6doQvkX392JqyFsR_lNMhPWyDmChbr0PAnZRTs-zzJHDTXPCTW82mR17cdqMzVBtiuiSEWFuBHIeXvuDHOVQ-f7GKn8ehl6al7ZRFBEKhTfyNhj4YyF91hmxhodMuH1a3HxQ6rsVjS5H2o03jzdTKfjczFMnkQTWrDx82zzMFuNopcVIqr_FX4ajp5kuxmmPaZky3YSrkJ8futH0ZMsKkcljKMSuGyKwJSC5aL2pBqfYxLY2UEyDiDZxySwvYOEDyANjkngQRlJHkO5GnKNH4p-dszZDGShAuUy-AQZwz4B5wQZY3ACzjEZNcJSyqWJHSLorsoQCaugOneSOOX-AuohMFQOLyOKSihkJqKUCUtAqqi6CqUsITK52CEvnpXHKNrwegNlt1nPqp5AuEAlYzDE3D2du8p4kIHL6mk-ElLjJFqityKzwSZ5gkzvYbZMJYMgl5TGnySFdxLKJN4GIufLtRuQKBrSOSIPUZqy0dwPgv4r7FhXF44OvyPZivZfGcQkbaK7LGC8_2o-n6ecxoPvxcs-3jzuALpsvRHZQ6EZV6Zt4RytNTfmmL4ALVKFMkVr290ru5ujYc8infkL0NZFm_JzDhuqzrsAtOze1cDKAU2vM-9aLwCkWR39OQdORNVKsS674p1j9Xq9DAi6_2NAM-KuFpwlUAkV2lVLvE9CMzK0Eqb4d0ZP_3DRP40dvfLvgF79ba7DL2z4YB2aer1oNfW0iyrFcHkHeVN0eRN0mW_laMtxoMvsKkdJwQMdrq-e5xS9SB06JB8dsksa2OUtJqYOFzwL0jLHudNVFivFXIWfd286FF1dVCAxYDGYuvjHowitsl7eZ2WBUmbKHkU98zK58nOx9CQ1XVtw39P6MU-orq0pXxOx1L4K7XstXtI1tKh9mHqEr-61-_Ab6GxI-JmxdaYGUIul1p-TIIJVsvHguQ19Ah1UIQLdDeUO7BlrfdyWEFr_q_ao9dudZquDLbOHOxe43cKWrm21ftdq9i56LRNb7Xan28Xdb7r2t9yz1exeWN_-B4pM7P4)

## Architecture Summary
```
Internet
    ↓
CloudFront CDN (d1ltovhjoc76pc.cloudfront.net)
    ↓
    ├─→ Bird Frontend (3000)
    │   ↓
    │   └─→ Bird API (4201)
    │       ↓
    │       └─→ Bird Image API (4200)
    │
    └─→ Direct API Routes (/api/*, /image/*)
        ↓
        Bird API & Image API Services

Monitoring Layer:
CloudWatch → SNS → Email Alerts (brunogatete77@gmail.com)

Auto-Scaling:
HPA: 2-10 pods per service (70% CPU trigger)
CA:  2-5 nodes (resource-based scaling)
```

## Comprehensive Documentation

This project includes extensive system design documentation covering architecture decisions, trade-offs, and best practices.

### System Design Blog Series

Here is the complete system design documentation on my technical blog:

**[https://gatete.hashnode.dev/system-design-and-documentation-for-a-production-grade-api-infrastructure-deployed-on-aws](https://gatete.hashnode.dev/system-design-and-documentation-for-a-production-grade-api-infrastructure-deployed-on-aws)**

Covers all five parts:
- **Part 1:** Architecture Overview & Technology Stack
- **Part 2:** Autoscaling & Resilience
- **Part 3:** Monitoring with CloudWatch
- **Part 4:** Cost Optimization
- **Part 5:** Multi-Region & Disaster Recovery

## Quick Start

### Prerequisites
- Terraform >= 1.5
- AWS CLI v2
- kubectl >= 1.29
- AWS account with administrative access

## Project Files
```
.
├── bird/                         # Bird API microservice
│   ├── Dockerfile
│   ├── main.go
│   ├── go.mod
│   └── Makefile
├── birdImage/                    # Bird Image API microservice
│   ├── Dockerfile
│   ├── main.go
│   ├── go.mod
│   └── Makefile
├── frontend/                     # Bird Frontend service (NEW)
│   ├── Dockerfile
│   └── main.go
├── bird-api-k8s-manifests/       # Kubernetes manifests (original)
│   ├── bird-api-deployment.yaml
│   └── bird-image-deployment.yaml
├── bird-chart/                   # Helm chart
│   ├── Chart.yaml
│   └── templates/
├── infrastructure/               # Terraform Infrastructure as Code
│   ├── *.tf                      (15 Terraform files)
│   ├── terraform.tfvars          (Configuration values)
│   ├── failure-simulation.sh      (Resilience test script - UPDATED)
│   ├── .gitignore                (Excludes state files)
│   ├── ARCHITECTURE.md           (System architecture)
│   └── RESILIENCE_TEST_RESULTS.md (Failure test results)
├── .github/workflows/
│   └── docker-ci.yml             (GitHub Actions pipeline - UPDATED)
└── README.md                     
```

### Deploy in 5 Steps
```bash
cd infrastructure
terraform init
terraform plan
terraform apply
aws eks update-kubeconfig --region us-east-1 --name bird-api-cluster
```

Deployment takes ~20 minutes.

## Containerization & CI/CD

Three microservices (Bird API, Bird Image API, and Bird Frontend) are containerized and automatically built on every push to `main` branch via GitHub Actions.

### Container Images
```bash
# Automatically pushed to Docker Hub
docker pull bruno74t/bird-api:v.1.0.5.7
docker pull bruno74t/bird-image-api:v.1.0.5.7
docker pull bruno74t/bird-frontend:v.1.0.5.7
```

### GitHub Actions Workflow
- **Trigger:** Push or pull request to `main` branch
- **Pipeline:**
  - Code checkout and Docker Buildx setup
  - Docker Hub authentication
  - Build and push all three container images with version tags:
    - bird-api
    - bird-image-api
    - bird-frontend (NEW)

- **Secrets Required:**
  - `DOCKER_USERNAME`: Docker Hub username
  - `DOCKER_PASSWORD_SYMBOLS_ALLOWED`: Docker Hub credentials

EKS automatically pulls latest images during pod initialization.

## API Endpoints

Get your service endpoints programmatically (they change on each deployment):
```bash
# Bird Frontend Service Endpoint (Load Balancer)
kubectl get svc bird-frontend-service -n default -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

# Bird API Service Endpoint (Load Balancer)
kubectl get svc bird-api-service -n default -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

# Bird Image API Service Endpoint (Load Balancer)
kubectl get svc bird-image-api-service -n default -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

# CloudFront CDN URL (Primary endpoint)
terraform output bird_frontend_cloudfront_url
```

### Direct (No Cache)

Replace with your actual endpoints from above:
- **Bird Frontend:** `http://a9e7f3ea9637c478ca3859b22fa0dca2-889582477.us-east-1.elb.amazonaws.com`
- **Bird API:** `http://a5d6bdfc70caf4284aa4829a6909552f-813628650.us-east-1.elb.amazonaws.com`
- **Bird Image API:** `http://a447b3c1e2c634ba5b9efb1e1944f063-1813333208.us-east-1.elb.amazonaws.com`

### Via CloudFront CDN (Cached, Recommended)
- **Primary URL:** `http://d1ltovhjoc76pc.cloudfront.net`
- Serves the Bird Frontend by default
- Routes `/api/*` paths to Bird API
- Routes `/image/*` paths to Bird Image API
- 5-minute cache for faster response times

### Test the Services
```bash
# Test Frontend (opens in browser)
open $(terraform output -raw bird_frontend_cloudfront_url)

# Test Bird API directly
curl http://d1ltovhjoc76pc.cloudfront.net/api

# Test Bird Image API
curl http://d1ltovhjoc76pc.cloudfront.net/image?birdName=Cardinal
```

## Verify Deployment
```bash
# Check nodes
kubectl get nodes

# Check pods (should show 3 deployments with 2 replicas each)
kubectl get pods -n default

# Check services (should show 3 LoadBalancers)
kubectl get svc -n default

# Monitor HPA (shows auto-scaling status)
watch kubectl get hpa -n default
```

## Monitoring & Alerting

### CloudWatch Dashboard
```
https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#dashboards:name=bird-api-overview
```

### Email Alerts

CloudWatch alarms are configured to send email notifications to your registered email address:

#### Alert Configuration
```bash
# Set your email in terraform.tfvars
alert_email = "your-email@example.com"

# Subscribe to SNS topic (confirm email from AWS)
# Then alarms will trigger for:
# - CPU utilization > 20%
# - Memory utilization > 30%
# - Pod restarts >= 3 times in 2 minutes
# - Node not ready status
```

#### Alarm Topics
- **pod-cpu-high:** Triggers when CPU exceeds 20%
- **pod-memory-high:** Triggers when memory exceeds 30%
- **pod-restarts-high:** Triggers on 3+ restarts in 2 minutes
- **node-not-ready:** Triggers when a node fails

### Check Alarms
```bash
aws cloudwatch describe-alarms --region us-east-1
```

### View Logs
```bash
# Frontend logs
kubectl logs -f deployment/bird-frontend -n default

# API logs
kubectl logs -f deployment/bird-api -n default

# Image API logs
kubectl logs -f deployment/bird-image-api -n default

# CloudWatch logs
aws logs tail /aws/eks/bird-api-cluster/applications --follow
```

## Failure Recovery & Testing

The system automatically recovers from:
- Pod crashes: <15 seconds
- Node failures: <5 minutes
- AZ failures: <2 minutes
- High CPU/memory load: Auto-scales to handle demand

### Automated Failure Simulation Script

Test system resilience with the comprehensive failure simulation script:
```bash
cd infrastructure
./failure-simulation.sh
```

### What the Script Tests

The script runs four critical failure scenarios:

1. **CPU Load Spike**
   - Generates high CPU load on pods
   - Tests CPU alarm triggering (threshold: 20%)
   - Duration: 5 minutes
   - Expected: Alert email sent, HPA scales pods

2. **Memory Pressure**
   - Creates memory-intensive workload
   - Tests memory alarm triggering (threshold: 30%)
   - Duration: 5 minutes
   - Expected: Alert email sent, system remains stable

3. **Node Failure Simulation**
   - Cordons a node to simulate failure
   - Tests node recovery mechanisms
   - Duration: 2 minutes
   - Expected: Pods migrate, node auto-recovered

4. **Pod Restart Loop**
   - Force-deletes 7 pods in rapid succession
   - Tests pod restart alarm (threshold: 3+ restarts)
   - Duration: 70 seconds
   - Expected: Alert email sent, pods auto-recreated

### Monitoring Test Results

After the test completes:

1. **Check Alarms**
```bash
   aws cloudwatch describe-alarms --region us-east-1 --query 'MetricAlarms[?starts_with(AlarmName, `bird-api`)].{Name:AlarmName,State:StateValue}'
```

2. **Verify Pod Recovery**
```bash
   kubectl get pods -n default
   kubectl get deployment -n default
```

3. **Check Email**
   - Look for alerts from AWS SNS
   - Subject: "ALARM: bird-api-pod-cpu-high"
   - Contains: Alarm details, thresholds, recovery actions

4. **View CloudWatch Dashboard**
```bash
   # Open CloudWatch console to see metrics during test
   https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#dashboards:name=bird-api-overview
```

## Auto-Scaling

### Pod Auto-Scaling (HPA)

Each service scales independently based on CPU utilization:

#### Bird Frontend
- Min: 2 replicas
- Max: 10 replicas
- Trigger: 70% CPU utilization

#### Bird API
- Min: 2 replicas
- Max: 10 replicas
- Trigger: 70% CPU utilization

#### Bird Image API
- Min: 2 replicas
- Max: 10 replicas
- Trigger: 70% CPU utilization

### Node Auto-Scaling

- Min: 2 nodes (high availability)
- Max: 5 nodes
- Automatically adds nodes when pods can't be scheduled
- Automatically removes underutilized nodes

Monitor:
```bash
# Check HPA status
kubectl get hpa -n default

# Watch scaling in action
watch kubectl get hpa,pods -n default

# Check node utilization
kubectl top nodes
kubectl top pods -n default
```

## Container Images & Versions

### Update Container Images

To update the container images deployed in your EKS cluster:

#### Navigate to Infrastructure Directory First

**All Terraform commands must be run from the `infrastructure/` directory:**
```bash
cd infrastructure
```

#### Update Image Versions

Current deployed versions are defined in **`variables.tf`** with defaults:
```hcl
variable "bird_api_image" {
  default = "bruno74t/bird-api:v.1.0.5.7"
}

variable "bird_image_api_image" {
  default = "bruno74t/bird-image-api:v.1.0.5.7"
}

variable "bird_frontend_image" {
  default = "bruno74t/bird-frontend:v.1.0.5.7"
}
```

**Update `variables.tf`** (Recommended)

Edit `variables.tf` directly:
```hcl
variable "bird_api_image" {
  default = "bruno74t/bird-api:v.1.0.5.8"  # Change version
}

variable "bird_image_api_image" {
  default = "bruno74t/bird-image-api:v.1.0.5.8"  # Change version
}

variable "bird_frontend_image" {
  default = "bruno74t/bird-frontend:v.1.0.5.8"  # Change version
}
```

#### Review and Deploy Changes
```bash
# Always review changes first
terraform plan

# Deploy if changes look good
terraform apply
```

#### Monitor Rollout
```bash
# Watch pods being replaced (all 3 services)
kubectl get pods -n default -w

# Check rollout status
kubectl rollout status deployment/bird-api -n default
kubectl rollout status deployment/bird-image-api -n default
kubectl rollout status deployment/bird-frontend -n default

# Verify new images are running
kubectl get deployments -o jsonpath='{.items[*].spec.template.spec.containers[*].image}'
```

#### Rollback to Previous Version

If the new version has issues:
```bash
# Update back to previous version
terraform apply \
  -var bird_api_image=bruno74t/bird-api:v.1.0.5.7 \
  -var bird_image_api_image=bruno74t/bird-image-api:v.1.0.5.7 \
  -var bird_frontend_image=bruno74t/bird-frontend:v.1.0.5.7

# Verify rollback
kubectl rollout status deployment/bird-api -n default
kubectl rollout status deployment/bird-image-api -n default
kubectl rollout status deployment/bird-frontend -n default
```

Current versions:
- `v.1.0.5.7` - Latest (currently deployed)
- `v.1.0.5` - Previous
- `v.1.0.0` - Initial
- `latest` - Points to v.1.0.5.7

## Cleanup

Destroy all infrastructure:
```bash
cd infrastructure
terraform destroy
```

Type `yes` to confirm. Costs stop immediately.

## Tech Stack

- **Orchestration:** Kubernetes (AWS EKS)
- **Infrastructure:** Terraform (Infrastructure as Code)
- **Monitoring:** AWS CloudWatch + SNS
- **CDN:** AWS CloudFront
- **Load Balancing:** AWS ELB (Elastic Load Balancer)
- **Containerization:** Docker
- **CI/CD:** GitHub Actions
- **Container Registry:** Docker Hub
- **Application:** Go (Golang)
- **Caching:** CloudFront (5-minute TTL)