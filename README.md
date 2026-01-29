# Bird API - Highly Available Infrastructure on AWS

Production-grade API infrastructure deployed on AWS EKS with auto-scaling, CloudFront CDN, and comprehensive monitoring.

## System Architecture Visualization

View interactive diagram: [System Architecture on Mermaid](https://mermaid.live/view#pako:eNqtWN1u2zYUfhVCxYYOsx2Jkn8iDAUcuWmLOp1Ruw3QeRe0RNtaZNGjpCRe3dvdby-wq73YnmCPsENSli1LTpCVDsCQPOd8PIc8P6Q-Gz4LqOEaC07WSzS5mMYIfkk2UxP96_FPUwNa1Pd9lsUpem7jHu7YPdztOPi7qfGzkihJeYN3IOVFLAsuOQMhmChxip93WeYZhEnKw1mWhiz-YcbPXgRWlLLb5S_M73bWfssXrHPB2oppKjnaaBXGaDIZIo_4S1pagsbBflCj48eRB-tDiyyzJf_OrE5FyYJ9lM2i0AcJ1UHjbAZaJOh5ljQpSdKmRRqo6M--qyCJ35tX14DwJk4pB2H0iqT0jmxqWd_1J8AK7Y4rqbCVLCxbWVadh7eAIXRXvZ3ytQu_fCtOHFrkwVZzFqFRRGIq93sW8qBJ1mHTj7IEjJCTb7OZNIcmyGrh81rQ6szewz4RYSh4IXrFWbZGzf02klowuT3Abwk9PYxS3FrRIMxWUh15mpZpte5PCo9YIGR31rgONq2HmPGOOVyRBd2JmLUilUN51PzZSfNnD5qPHzIfP2y-_RTzna8xvzTxWEwOL2CpISMBuiDgdH4YLyqrvBteiMODfy4q_DGh_Db0lZOOGE9Rz_zn9z9rDQNBXJIvrDqNYj4ps4x9EoHmIm9mKWvmw4oir0d9YIFWrncVxi5uoCty71qmnJkQvoAk4Y0-uKhrflPNn32ZP2UgIrFSAgvlMXmA1kYxOEvyJAuuWBymjAN-3gP90bdoyBaLOku8610mvyapv6zQQS6RB7tQPp5IHc_IXXJGb5Kzw2RSTJL1GtIsEcWgmqf6EeGrpLRoPidBYMvAdrpifNOQoZI00HuapITX5LwBSZYzRngAcEW_nO3YrXAMeldTwnLTxja6yPybvCwdFDVBP06duzLWjID4NM9KVR6X_-F0Y_DcFY3TimJju6JUoQBsNSdzxlfNRMBI4kfKE9hpcczfo5exzzdrsfPVzRqICB1sYrJig4tTuBHzb5TVStEhjI_9pjC16BzdPHZV8qBglgA-QLSKrf_3rz_-VgMVt6o8T0CVeegXEkerSH7UbL7Yvp5MRmeiGW_hOBXVu5QkeadAV2GikH_kIXg_ONKvGfjSVhRzxQ4dyf-eZSndygR1ioAPlRCMkn6Q8YBNVKfHGOwjHFzPhh9jcEo4oqYKvkMVDufwfg7v5uyauRKqwJKLX1G43vnJViS-goRPk-zTJOcESbUwlHSReMFMuMrUWrmX9_pHRlRJnoLsB4FKKBXYwkwR8VsZ90dG1hDsUwSnllDyTkVUGeiQLG5uZRNyNxWMiqJy-p7iKTftQ_UAv1aJtESBq_k6IpvtPlkergh5ptkS-y2CfStyhJqHjiKI-N8CWynO001ExfMCzcMocp_R3tyatxs-ixh3n1nEJm3cgAcBu6HuMxx0SY_kw-ZdGKRLF6_vD5HghZEj5cw50nw-L2BKqCdgLnWgiMDXACNu_xpghEcomJy5BsYMrDkOHtZGBo4mIKwDSMacHhxd-tiacBwtGy3qhx4cLfsjErMGGE8Pyi5E7aBNeub_jC2ZVDXgqKSrA6lI0TrAVHnRlKLHtiYgUVj0IKl7oAZvEt-R9KiUX2A1geUffPSg9T8RbUgzTUhDXa6QP9M1oeV3LF26pfoOsfj6-LVwqoU9uxlL4IDOSRalqIga0yxLWut7o2EseBgYbsoz2jBWlK-IGBqfBdrUSJfwnp0aLnQDwm-mxjT-AjJrEn9ibLUT4yxbLA13TqIERtk6gN0ZhATejXsWePBR7okv1obbxRLCcD8b94bbtCyr1eu2TdNpt7uOY3e6DWNjuFbbbPVsfN4x27Zz3nO-NIzf5KJWy-p0zjHu2ufYcc7bVvfLfz_xEfM)

## Quick Start

### Prerequisites
- Terraform >= 1.5
- AWS CLI v2
- kubectl >= 1.29
- AWS account with adminstrative access

### Deploy in 5 Steps
```bash
cd infrastructure
terraform init
terraform plan
terraform apply
aws eks update-kubeconfig --region us-east-1 --name bird-api-cluster
```

Deployment takes ~20 minutes.

## API Endpoints

### Direct (No Cache)
- Bird API: `http://a5d6bdfc70caf4284aa4829a6909552f-813628650.us-east-1.elb.amazonaws.com`
- Bird Image API: `http://a447b3c1e2c634ba5b9efb1e1944f063-1813333208.us-east-1.elb.amazonaws.com`

### Via CloudFront CDN (Cached, Recommended)
- `http://d1ltovhjoc76pc.cloudfront.net`

### Test
```bash
curl http://d1ltovhjoc76pc.cloudfront.net
```

## Verify Deployment
```bash
# Check nodes
kubectl get nodes

# Check pods
kubectl get pods -n default

# Check services
kubectl get svc -n default

# Monitor HPA
watch kubectl get hpa -n default
```

## Key Features

- Multi-AZ deployment across 2 availability zones
- Auto-scaling: HPA (2-10 pods) + Cluster Autoscaler (2-5 nodes)
- CloudFront CDN with 5-minute caching
- CloudWatch monitoring with 4 alarms
- Self-healing: pod/node failures recover automatically
- Infrastructure as Code: 14 Terraform files

## Containerization & CI/CD

Two microservices (Bird API and Bird Image API) are containerized and automatically built on every push to `main` branch via GitHub Actions.

### Container Images
```bash
# Automatically pushed to Docker Hub
docker pull {DOCKER_USERNAME}/bird-api:v.1.0.2
docker pull {DOCKER_USERNAME}/bird-image-api:v.1.0.2
```

### GitHub Actions Workflow
Trigger: Push or pull request to `main` branch

**Pipeline:**
- Code checkout and Docker Buildx setup
- Docker Hub authentication
- Build and push both API container images with version tags

**GitHub Secrets Required:**
```
DOCKER_USERNAME: Docker Hub username
DOCKER_PASSWORD_SYMBOLS_ALLOWED: Docker Hub credentials
```

EKS automatically pulls latest images during pod initialization.

## Monitoring

### CloudWatch Dashboard
```bash
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

## Failure Recovery

The system automatically recovers from:
- Pod crashes: <15 seconds
- Node failures: <5 minutes
- AZ failures: <2 minutes

Test resilience:
```bash
./failure-simulation.sh
```

## Cleanup

Destroy all infrastructure:
```bash
terraform destroy
```

## Comprehensive Documentation

This project includes extensive system design documentation covering architecture decisions, trade-offs, and best practices.

### System Design Blog Series

Read the complete system design documentation on my blog:

#### [Part 1: Architecture Overview & Technology Selection](https://hashnode.com/draft/697a6f19a4825b20aaaffe85)
- Why we chose EKS over alternatives
- Load balancer comparison (NLB vs ALB vs Classic LB)
- Container orchestration decision framework
- Technology selection rationale

#### [Part 2: Autoscaling & Resilience](https://hashnode.com/draft/697a6f19a4825b20aaaffe85)
- Horizontal Pod Autoscaling (HPA) explained
- Why 70% CPU threshold?
- Cluster Autoscaler configuration
- Failure recovery mechanisms
- Pod Disruption Budgets
- Real-world resilience testing

#### [Part 3: Monitoring with CloudWatch](https://hashnode.com/draft/697a6f19a4825b20aaaffe85)
- Metrics selection strategy
- CloudWatch vs Prometheus comparison
- Four critical alarms explained
- Log Insights queries
- Alert fatigue prevention
- Cost of monitoring

#### [Part 4: Cost Optimization](https://hashnode.com/draft/697a6f19a4825b20aaaffe85)
- Current cost breakdown ($120-140/month)
- Spot instances strategy (70% savings)
- ECS Fargate comparison
- Reserved instances ROI
- Break-even analysis
- Cost optimization roadmap

#### [Part 5: Multi-Region & Disaster Recovery](https://hashnode.com/draft/697a6f19a4825b20aaaffe85)
- Multi-region architecture
- Active-Active vs Active-Passive
- RTO/RPO metrics
- Database replication strategies
- DR testing procedures
- Cost-benefit analysis

## Tech Stack

- **Orchestration:** Kubernetes (AWS EKS)
- **Infrastructure:** Terraform (IaC)
- **Monitoring:** AWS CloudWatch
- **CDN:** AWS CloudFront
- **Containerization:** Docker
- **CI/CD:** GitHub Actions
- **Registry:** Docker Hub


---