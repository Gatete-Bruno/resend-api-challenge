# Bird API - Highly Available Infrastructure on AWS

Production-grade API infrastructure deployed on AWS EKS with auto-scaling, CloudFront CDN, and comprehensive monitoring.

## System Architecture Visualization

[System Architecture Diagram](https://mermaid.live/view#pako:eNqtWN1u2zYUfhVCxYYOsx2Jkn8iDAUcuWmLOp1Ruw3QeRe0RNtaZNGjpCRe3dvdby-wq73YnmCPsENSli1LTpCVDsCQPOd8PIc8P6Q-Gz4LqOEaC07WSzS5mMYIfkk2UxP96_FPUwNa1Pd9lsUpem7jHu7YPdztOPi7qfGzkihJeYN3IOVFLAsuOQMhmChxip93WeYZhEnKw1mWhiz-YcbPXgRWlLLb5S_M73bWfssXrHPB2oppKjnaaBXGaDIZIo_4S1pagsbBflCj48eRB-tDiyyzJf_OrE5FyYJ9lM2i0AcJ1UHjbAZaJOh5ljQpSdKmRRqo6M--qyCJ35tX14DwJk4pB2H0iqT0jmxqWd_1J8AK7Y4rqbCVLCxbWVadh7eAIXRXvZ3ytQu_fCtOHFrkwVZzFqFRRGIq93sW8qBJ1mHTj7IEjJCTb7OZNIcmyGrh81rQ6szewz4RYSh4IXrFWbZGzf02klowuT3Abwk9PYxS3FrRIMxWUh15mpZpte5PCo9YIGR31rgONq2HmPGOOVyRBd2JmLUilUN51PzZSfNnD5qPHzIfP2y-_RTzna8xvzTxWEwOL2CpISMBuiDgdH4YLyqrvBteiMODfy4q_DGh_Db0lZOOGE9Rz_zn9z9rDQNBXJIvrDqNYj4ps4x9EoHmIm9mKWvmw4oir0d9YIFWrncVxi5uoCty71qmnJkQvoAk4Y0-uKhrflPNn32ZP2UgIrFSAgvlMXmA1kYxOEvyJAuuWBymjAN-3gP90bdoyBaLOku8610mvyapv6zQQS6RB7tQPp5IHc_IXXJGb5Kzw2RSTJL1GtIsEcWgmqf6EeGrpLRoPidBYMvAdrpifNOQoZI00HuapITX5LwBSZYzRngAcEW_nO3YrXAMeldTwnLTxja6yPybvCwdFDVBP06duzLWjID4NM9KVR6X_-F0Y_DcFY3TimJju6JUoQBsNSdzxlfNRMBI4kfKE9hpcczfo5exzzdrsfPVzRqICB1sYrJig4tTuBHzb5TVStEhjI_9pjC16BzdPHZV8qBglgA-QLSKrf_3rz_-VgMVt6o8T0CVeegXEkerSH7UbL7Yvp5MRmeiGW_hOBXVu5QkeadAV2GikH_kIXg_ONKvGfjSVhRzxQ4dyf-eZSndygR1ioAPlRCMkn6Q8YBNVKfHGOwjHFzPhh9jcEo4oqYKvkMVDufwfg7v5uyauRKqwJKLX1G43vnJViS-goRPk-zTJOcESbUwlHSReMFMuMrUWrmX9_pHRlRJnoLsB4FKKBXYwkwR8VsZ90dG1hDsUwSnllDyTkVUGeiQLG5uZRNyNxWMiqJy-p7iKTftQ_UAv1aJtESBq_k6IpvtPlkergh5ptkS-y2CfStyhJqHjiKI-N8CWynO001ExfMCzcMocp_R3tyatxs-ixh3n1nEJm3cgAcBu6HuMxx0SY_kw-ZdGKRLF6_vD5HghZEj5cw50nw-L2BKqCdgLnWgiMDXACNu_xpghEcomJy5BsYMrDkOHtZGBo4mIKwDSMacHhxd-tiacBwtGy3qhx4cLfsjErMGGE8Pyi5E7aBNeub_jC2ZVDXgqKSrA6lI0TrAVHnRlKLHtiYgUVj0IKl7oAZvEt-R9KiUX2A1geUffPSg9T8RbUgzTUhDXa6QP9M1oeV3LF26pfoOsfj6-LVwqoU9uxlL4IDOSRalqIga0yxLWut7o2EseBgYbsoz2jBWlK-IGBqfBdrUSJfwnp0aLnQDwm-mxjT-AjJrEn9ibLUT4yxbLA13TqIERtk6gN0ZhATejXsWePBR7okv1obblgiG-9m4N1zbaTl21znvneN25_y87TSMjeFajtNq22anbXfMc8fsdpwvDeM3uabZ6nXbX_4DY4MPLw)



## Comprehensive Documentation

This project includes extensive system design documentation covering architecture decisions, trade-offs, and best practices.

### System Design Blog Series

Here is the complete system design documentation on my technical blog:

**[https://gatete.hashnode.dev/system-design-and-documentation-for-a-production-grade-api-infrastructure-deployed-on-aws](https://gatete.hashnode.dev/system-design-and-documentation-for-a-production-grade-api-infrastructure-deployed-on-aws)**

Covers all five parts:
- **Part 1:** Architecture Overview & Technology Selection
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
├── bird-api-k8s-manifests/       # Kubernetes manifests (original)
│   ├── bird-api-deployment.yaml
│   └── bird-image-deployment.yaml
├── bird-chart/                   # Helm chart
│   ├── Chart.yaml
│   └── templates/
├── infrastructure/               # Terraform Infrastructure as Code
│   ├── *.tf                      (14 Terraform files)
│   ├── terraform.tfvars          (Configuration values)
│   ├── failure-simulation.sh      (Resilience test script)
│   ├── .gitignore                (Excludes state files)
│   ├── ARCHITECTURE.md           (System architecture)
│   └── RESILIENCE_TEST_RESULTS.md (Failure test results)
├── .github/workflows/
│   └── docker-ci.yml             (GitHub Actions pipeline)
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

Two microservices (Bird API and Bird Image API) are containerized and automatically built on every push to `main` branch via GitHub Actions.

### Container Images
```bash
# Automatically pushed to Docker Hub
docker pull bruno74t/bird-api:v.1.0.2
docker pull bruno74t/bird-image-api:v.1.0.2
```

### GitHub Actions Workflow
- **Trigger:** Push or pull request to `main` branch
- **Pipeline:**
  - Code checkout and Docker Buildx setup
  - Docker Hub authentication
  - Build and push both API container images with version tags

- **Secrets Required:**
  - `DOCKER_USERNAME`: Docker Hub username
  - `DOCKER_PASSWORD_SYMBOLS_ALLOWED`: Docker Hub credentials

EKS automatically pulls latest images during pod initialization.

## API Endpoints

### Get Endpoints Dynamically

Get your service endpoints programmatically (they change on each deployment):
```bash
# Bird API Service Endpoint (Load Balancer)
kubectl get svc bird-api-service -n default -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

# Bird Image API Service Endpoint (Load Balancer)
kubectl get svc bird-image-api-service -n default -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

# CloudFront CDN URL
terraform output bird_api_cloudfront_url
```

### Direct (No Cache)

Replace with your actual endpoints from above:
- **Bird API:** `http://a5d6bdfc70caf4284aa4829a6909552f-813628650.us-east-1.elb.amazonaws.com`
- **Bird Image API:** `http://a447b3c1e2c634ba5b9efb1e1944f063-1813333208.us-east-1.elb.amazonaws.com`

### Via CloudFront CDN (Cached, Recommended)
- **CDN URL:** `http://d1ltovhjoc76pc.cloudfront.net`

### Test the API
```bash
# Get CloudFront URL and test
curl $(terraform output -raw bird_api_cloudfront_url)

# Or test with specific endpoint
curl http://d1ltovhjoc76pc.cloudfront.net
```

## Verify Deployment
```bash
# Check nodes
kubectl get nodes

# Check pods
kubectl get pods -n default

# Check services and get endpoints
kubectl get svc -n default

# Monitor HPA
watch kubectl get hpa -n default
```

## Key Features

- Multi-AZ deployment across 2 availability zones
- Auto-scaling: HPA (2-10 pods) + Cluster Autoscaler (2-5 nodes)
- CloudFront CDN with 5-minute caching
- CloudWatch monitoring with 4 alarms
- Self-healing: pod/node failures recover automatically (<15 seconds)
- Infrastructure as Code: 14 Terraform files
- Automated CI/CD with GitHub Actions
- Docker containerization for both microservices

## Monitoring

### CloudWatch Dashboard
```
https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#dashboards:name=bird-api-overview
```

### Check Alarms
```bash
aws cloudwatch describe-alarms --region us-east-1
```

### View Logs
```bash
# Pod logs
kubectl logs -f deployment/bird-api -n default

# CloudWatch logs
aws logs tail /aws/eks/bird-api-cluster/applications --follow
```

## Auto-Scaling

### Pod Auto-Scaling (HPA)
- Min: 2 replicas
- Max: 10 replicas
- Triggers at: 70% CPU utilization
- Scales down after: 5 minutes below threshold

### Node Auto-Scaling
- Min: 2 nodes
- Max: 5 nodes
- Automatically adds nodes when pods can't be scheduled

Monitor:
```bash
kubectl get hpa -n default
kubectl get nodes
```

## Container Images & Versions

### Check Current Deployed Images
```bash
# View all container images currently deployed
kubectl get deployments -o jsonpath='{.items[*].spec.template.spec.containers[*].image}'

# Example output:
# bruno74t/bird-api:v.1.0.2 bruno74t/bird-image-api:v.1.0.2

# More readable format (one deployment per line)
kubectl get deployments -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.template.spec.containers[*].image}{"\n"}{end}'

# Get just bird-api image
kubectl get deployment bird-api -o jsonpath='{.spec.template.spec.containers[0].image}'

# Get just bird-image-api image
kubectl get deployment bird-image-api -o jsonpath='{.spec.template.spec.containers[0].image}'
```

### Update Container Images

To update the container images deployed in your EKS cluster:

#### Navigate to Infrastructure Directory First

**All Terraform commands must be run from the `infrastructure/` directory:**
```bash
cd infrastructure
```

If you're not in the `infrastructure/` directory, you'll get:
```
Error: No configuration files
```

#### Update Image Versions

Current deployed versions are defined in **`variables.tf`** with defaults:
```hcl
variable "bird_api_image" {
  default = "bruno74t/bird-api:v.1.0.2"
}

variable "bird_image_api_image" {
  default = "bruno74t/bird-image-api:v.1.0.2"
}
```

**Update `variables.tf`** (Alternative)

Edit `variables.tf` directly:
```hcl
variable "bird_api_image" {
  default = "bruno74t/bird-api:v.1.0.3"  # Change version
}

variable "bird_image_api_image" {
  default = "bruno74t/bird-image-api:v.1.0.3"  # Change version
}
```


#### Review and Deploy Changes
```bash
# Always review changes first
terraform plan

# You'll see:
# kubernetes_deployment.bird_api will be updated in-place
#  ~ image = "bruno74t/bird-api:v.1.0.2" -> "bruno74t/bird-api:v.1.0.3"

# Deploy if changes look good
terraform apply
```

#### Monitor Rollout
```bash
# Watch pods being replaced
kubectl get pods -n default -w

# Check rollout status
kubectl rollout status deployment/bird-api -n default
kubectl rollout status deployment/bird-image-api -n default

# Verify new images are running
kubectl get deployments -o jsonpath='{.items[*].spec.template.spec.containers[*].image}'
```

#### Rollback to Previous Version

If the new version has issues:
```bash
# Update back to previous version
terraform apply \
  -var bird_api_image=bruno74t/bird-api:v.1.0.2 \
  -var bird_image_api_image=bruno74t/bird-image-api:v.1.0.2

# Verify rollback
kubectl rollout status deployment/bird-api -n default
```

### Available Image Versions

Check Docker Hub for available versions:
- [bruno74t/bird-api tags](https://hub.docker.com/r/bruno74t/bird-api/tags)
- [bruno74t/bird-image-api tags](https://hub.docker.com/r/bruno74t/bird-image-api/tags)

Current versions:
- `v.1.0.2` - Latest (currently deployed)
- `v.1.0.1` - Previous
- `v.1.0.0` - Initial
- `latest` - Points to v.1.0.2

### Troubleshooting Image Updates

**Error: "No configuration files"**
```bash
# Make sure you're in the infrastructure directory
cd infrastructure
terraform plan
```

**Pods not updating**
```bash
# Force pod restart
kubectl rollout restart deployment/bird-api -n default
kubectl rollout restart deployment/bird-image-api -n default
```

**Check image pull errors**
```bash
kubectl describe pod <pod-name> -n default
kubectl logs <pod-name> -n default
```

## Failure Recovery

The system automatically recovers from:
- Pod crashes: <15 seconds
- Node failures: <5 minutes
- AZ failures: <2 minutes

Test resilience:
```bash
./failure-simulation.sh
```

See detailed results: `RESILIENCE_TEST_RESULTS.md`

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
- **Monitoring:** AWS CloudWatch
- **CDN:** AWS CloudFront
- **Containerization:** Docker
- **CI/CD:** GitHub Actions
- **Container Registry:** Docker Hub
- **Application:** Go (Golang)


