# Bird API - Highly Available Infrastructure on AWS

Production-grade API infrastructure deployed on AWS EKS with auto-scaling, CloudFront CDN, and comprehensive monitoring.

## Quick Start

### Prerequisites
- Terraform >= 1.5
- AWS CLI v2
- kubectl >= 1.29
- AWS account with appropriate permissions

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

See results: `RESILIENCE_TEST_RESULTS.md`

## Cost

10-day deployment: ~$34
- EKS Control Plane: $24
- EC2 nodes: $4.50
- Load Balancers: $1.40
- CloudFront: $2
- Others: $2.10

## Cleanup

Destroy all infrastructure:
```bash
terraform destroy
```

Type `yes` to confirm. Costs stop immediately.

## Documentation

For detailed documentation, see:
- **Architecture & Design**: See `ARCHITECTURE.md` or visit my blog
- **Monitoring Setup**: Check my blog for CloudWatch guide
- **Troubleshooting**: Blog post with common issues
- **Cost Analysis**: Blog breakdown of expenses
- **Maintenance**: Blog guide for updates and scaling

[Link to your blog here]

## Files

- `*.tf` - Terraform Infrastructure as Code
- `terraform.tfvars` - Configuration values
- `failure-simulation.sh` - Resilience test script
- `ARCHITECTURE.md` - System architecture diagram
- `RESILIENCE_TEST_RESULTS.md` - Failure test results

## Tech Stack

- Kubernetes (EKS)
- Terraform (IaC)
- CloudWatch (Monitoring)
- CloudFront (CDN)
- Docker (Containerization)

---

