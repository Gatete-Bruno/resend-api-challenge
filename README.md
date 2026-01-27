# Bird API - Highly Available & Scalable Infrastructure on AWS

## Table of Contents

1. [Project Overview](#project-overview)
2. [Architecture](#architecture)
3. [Prerequisites](#prerequisites)
4. [Quick Start](#quick-start)
5. [Infrastructure Components](#infrastructure-components)
6. [Accessing the APIs](#accessing-the-apis)
7. [Auto-Scaling Behavior](#auto-scaling-behavior)
8. [Failure Recovery](#failure-recovery)
9. [Monitoring & Observability](#monitoring--observability)
10. [CloudFront CDN](#cloudfront-cdn)
11. [Troubleshooting](#troubleshooting)
12. [Cost Analysis](#cost-analysis)
13. [Maintenance](#maintenance)
14. [Cleanup](#cleanup)

---

## Project Overview

This project demonstrates a production-grade, highly available, and scalable API infrastructure deployed on AWS using Kubernetes (EKS). The solution implements best practices for reliability, performance, and observability.

### Key Features

- High Availability - Multi-AZ deployment across 2 availability zones
- Auto-Scaling - Both horizontal pod and cluster-level auto-scaling
- Load Balancing - AWS Network Load Balancers for traffic distribution
- CDN Integration - CloudFront for caching and global distribution
- Comprehensive Monitoring - CloudWatch alarms, dashboards, and logs
- Infrastructure as Code - Complete Terraform automation
- Self-Healing - Automatic pod and node recovery
- Stateless Design - Enables horizontal scaling

### Business Value

- 99.9% Uptime SLA - Multi-AZ architecture ensures availability
- Reduced Latency - CloudFront CDN serves responses from edge locations
- Cost Optimization - Auto-scaling prevents over-provisioning
- Operational Efficiency - Automated monitoring and self-healing
- Easy Replication - Infrastructure as Code enables quick deployments

---

## Architecture

### System Diagram

See `ARCHITECTURE.md` for the complete Mermaid diagram showing:
- VPC with public/private subnets
- EKS cluster with 2 node groups
- Load balancers and CloudFront CDN
- Auto-scaling components
- Monitoring and logging pipeline

### High-Level Flow
```
Internet Users
    |
CloudFront CDN (Cache 5 min TTL)
    |
AWS Network Load Balancers (2x)
    |
EKS Kubernetes Service
    |
Multiple Pods (bird-api & bird-image-api)
    |
CloudWatch Monitoring & Alarms
```

### Key Design Decisions

| Decision | Choice | Rationale | Trade-off |
|----------|--------|-----------|-----------|
| Container Orchestration | EKS (Managed) | AWS manages control plane | Slightly higher cost |
| Load Balancing | Network Load Balancer | Simple setup, low latency | Each service gets own LB |
| Pod Auto-scaling | HPA (CPU-based) | Standard Kubernetes, proven | Requires Metrics Server |
| Node Auto-scaling | Cluster Autoscaler | Native AWS support | Slower than Karpenter |
| Monitoring | CloudWatch | Native AWS, no extra infra | Limited vs Prometheus |
| Caching | CloudFront | Global CDN, easy setup | Cost for high traffic |
| Regions/AZs | 2 AZs in us-east-1 | HA + cost balance | Single AZ failure = 50% capacity |

---

## Prerequisites

### Local Machine Requirements
```bash
# Required tools
- Terraform >= 1.5
- AWS CLI v2
- kubectl >= 1.29
- git
- curl/wget
```

### AWS Account Requirements

- AWS account with appropriate IAM permissions
- Account ID: `328263827642` (update to yours)
- Region: `us-east-1` (configurable)
- VPC quota available

### AWS Permissions Needed

Your AWS user/role needs permissions for:
- EKS (cluster, node groups)
- EC2 (instances, security groups, VPC)
- IAM (roles, policies)
- CloudWatch (logs, alarms, dashboards)
- S3 (state bucket, logs)
- DynamoDB (state locking)
- CloudFront (distributions)

### Estimated Costs
```
EKS Control Plane:     $0.10/hour  (~$73/month)
2 x t2.medium nodes:   $0.05/hour  (~$36/month)
2 x Network LB:        $0.006/hour (~$4.30/month)
CloudFront:            Variable    (~$2-10/month for low traffic)
S3 + DynamoDB:         ~$2/month
CloudWatch:            ~$5/month
────────────────────────────────
Total:                 ~$120-130/month for dev environment
```

---

## Quick Start

### 1. Clone/Navigate to Project
```bash
cd bird-api-infrastructure
```

### 2. Initialize Terraform
```bash
# Download required providers and modules
terraform init

# Verify configuration
terraform fmt -recursive
terraform validate
```

### 3. Review the Plan
```bash
# See what will be created
terraform plan

# Save plan for review (optional)
terraform plan -out=tfplan
```

### 4. Deploy Infrastructure
```bash
# Create all resources (takes ~15-20 minutes for EKS)
terraform apply

# Or apply from saved plan
terraform apply tfplan
```

### 5. Configure kubectl
```bash
# Update kubeconfig to connect to EKS cluster
aws eks update-kubeconfig --region us-east-1 --name bird-api-cluster

# Verify connection
kubectl get nodes
```

### 6. Verify Deployment
```bash
# Check all pods are running
kubectl get pods -n default

# Check services and load balancers
kubectl get svc -n default

# Wait for LoadBalancer IPs (~2-3 minutes)
watch kubectl get svc -n default
```

### 7. Test APIs
```bash
# Get your endpoints
terraform output bird_api_service_endpoint
terraform output bird_image_api_service_endpoint
terraform output bird_api_cloudfront_url

# Test bird-api (direct)
curl http://a5d6bdfc70caf4284aa4829a6909552f-813628650.us-east-1.elb.amazonaws.com

# Test bird-image-api (direct)
curl http://a447b3c1e2c634ba5b9efb1e1944f063-1813333208.us-east-1.elb.amazonaws.com

# Test via CloudFront CDN
curl http://d1ltovhjoc76pc.cloudfront.net
```

---

## Infrastructure Components

### 1. VPC & Networking

**Configuration:**
- CIDR Block: `10.0.0.0/16`
- Availability Zones: `us-east-1a`, `us-east-1b`
- Public Subnets: `10.0.1.0/24`, `10.0.2.0/24`
- Private Subnets: `10.0.101.0/24`, `10.0.102.0/24`

**Features:**
- Internet Gateway for public subnet routing
- 2 NAT Gateways (one per AZ) for private subnet outbound traffic
- Route tables for public and private subnets
- Security groups restricting traffic

**Benefits:**
- Multi-AZ deployment for high availability
- Isolated private subnets for pod security
- Redundant NAT for fault tolerance

### 2. EKS Cluster

**Cluster Details:**
```
Name:                bird-api-cluster
Version:             Kubernetes 1.29
Region:              us-east-1
Control Plane:       AWS Managed (Multi-AZ by default)
Endpoint:            https://[cluster-endpoint].eks.amazonaws.com
Logging:             Enabled (api, audit, authenticator, controllerManager, scheduler)
```

**Security:**
- OIDC Provider configured for IRSA (IAM Roles for Service Accounts)
- Cluster endpoint access control enabled
- Audit logging enabled

**Add-ons:**
- aws-node (VPC CNI plugin)
- coredns (DNS service)
- kube-proxy (network proxy)

### 3. Node Groups

**Node Group Configuration:**

| Property | Value |
|----------|-------|
| Instance Type | t2.medium |
| Desired Size | 2 nodes |
| Min Size | 2 nodes |
| Max Size | 5 nodes |
| Disk Size | 50 GB |
| AZs | us-east-1a, us-east-1b |

**Node Details:**
- Each node runs Docker daemon and kubelet
- Nodes automatically join EKS cluster
- Auto Scaling Group manages node lifecycle
- Graceful termination support

**Monitoring:**
- CloudWatch metrics from node-level
- Node status monitoring via Cluster Autoscaler
- Self-healing via auto-recovery

### 4. Kubernetes Deployments

#### Bird API Deployment
```yaml
Name:                 bird-api
Container Image:      bruno74t/bird-api:v.1.0.1
Container Port:       4201
Initial Replicas:     2
HPA Min Replicas:     2
HPA Max Replicas:     10

Resource Requests:
  CPU:                100m (0.1 cores)
  Memory:             128Mi

Resource Limits:
  CPU:                500m (0.5 cores)
  Memory:             512Mi

Probes:
  Liveness:           HTTP GET /health (30s initial delay)
  Readiness:          HTTP GET /health (10s initial delay)
```

**Purpose:** Provides bird data API service

#### Bird Image API Deployment
```yaml
Name:                 bird-image-api
Container Image:      bruno74t/bird-image-api:v.1.0.1
Container Port:       4200
Initial Replicas:     2
HPA Min Replicas:     2
HPA Max Replicas:     10

Resource Requests:
  CPU:                100m (0.1 cores)
  Memory:             128Mi

Resource Limits:
  CPU:                500m (0.5 cores)
  Memory:             512Mi

Probes:
  Liveness:           HTTP GET /health (30s initial delay)
  Readiness:          HTTP GET /health (10s initial delay)
```

**Purpose:** Provides bird image service

### 5. Kubernetes Services & Load Balancing

#### Bird API Service
```yaml
Service Name:         bird-api-service
Service Type:         LoadBalancer (AWS NLB)
External Port:        80
Target Port:          4201 (pod port)
Load Balancer DNS:    a5d6bdfc70caf4284aa4829a6909552f-813628650.us-east-1.elb.amazonaws.com
Protocol:             TCP
Session Affinity:     None (stateless)
```

#### Bird Image API Service
```yaml
Service Name:         bird-image-api-service
Service Type:         LoadBalancer (AWS NLB)
External Port:        80
Target Port:          4200 (pod port)
Load Balancer DNS:    a447b3c1e2c634ba5b9efb1e1944f063-1813333208.us-east-1.elb.amazonaws.com
Protocol:             TCP
Session Affinity:     None (stateless)
```

**Load Balancer Features:**
- Health checks every 30 seconds
- Connection draining (300 seconds)
- Deregistration delay enabled
- Cross-zone load balancing enabled

### 6. Pod Disruption Budgets (PDB)

**Configuration:**
```yaml
PDB Name:             bird-api-pdb
Min Available:        1 pod (allows 1 pod to be disrupted)
Selector:             app=bird-api

PDB Name:             bird-image-api-pdb
Min Available:        1 pod (allows 1 pod to be disrupted)
Selector:             app=bird-image-api
```

**Purpose:**
- Ensures minimum availability during cluster maintenance
- Prevents accidental disruption of critical services
- Kubernetes respects PDB during voluntary disruptions

---

## Accessing the APIs

### Access Methods

#### Method 1: Direct Load Balancer (No Cache)

**Bird API:**
```bash
curl http://a5d6bdfc70caf4284aa4829a6909552f-813628650.us-east-1.elb.amazonaws.com
```

**Bird Image API:**
```bash
curl http://a447b3c1e2c634ba5b9efb1e1944f063-1813333208.us-east-1.elb.amazonaws.com
```

**Use Case:** Development/testing where you want fresh data on each request

#### Method 2: CloudFront CDN (Cached)
```bash
curl http://d1ltovhjoc76pc.cloudfront.net
```

**Advantages:**
- Responses cached for 5 minutes
- Served from edge locations (lower latency)
- Reduced backend load
- Lower bandwidth costs

**Use Case:** Production use where caching is acceptable

### API Response Example
```json
{
  "name": "Bird in disguise",
  "description": "This bird is in disguise because: ...",
  "image": "https://www.pokemonmillennium.net/wp-content/uploads/2015/11/missingno.png"
}
```

### Monitoring Requests

#### Check Request Headers
```bash
# See CloudFront cache status
curl -I http://d1ltovhjoc76pc.cloudfront.net

# Output:
# X-Cache: Hit from cloudfront      (cached response)
# X-Cache: Miss from cloudfront     (cache miss, fetched from origin)
# X-Amz-Cf-Pop: NBO50-P1            (edge location serving)
```

#### Real-time Request Monitoring
```bash
# Watch requests in real-time
kubectl logs -f deployment/bird-api -n default

# Watch all pods
kubectl logs -f -l app=bird-api -n default --all-containers=true
```

---

## Auto-Scaling Behavior

### Horizontal Pod Autoscaler (HPA)

#### How It Works

1. **Metrics Collection:**
   - Metrics Server collects CPU/Memory metrics from pods
   - Metrics collected every 15 seconds
   - Stored in Kubernetes metrics API

2. **Decision Making:**
   - HPA controller checks metrics every 15 seconds
   - Compares current CPU vs target CPU (70%)
   - Calculates desired replicas using formula:
```
     desiredReplicas = ceil[currentReplicas * (currentMetric / targetMetric)]
```

3. **Scaling Up:**
   - If CPU > 70% for 3 minutes → scale up
   - Adds 1 replica at a time
   - Max 10 replicas per deployment
   - New pod ready in ~2-5 seconds

4. **Scaling Down:**
   - If CPU < 70% for 5 minutes → scale down
   - Removes 1 replica at a time
   - Minimum 2 replicas (HA requirement)
   - Graceful termination (30 second drain)

#### Configuration
```hcl
HPA Settings:
  Min Replicas:        2 (always maintain HA)
  Max Replicas:        10 (prevent runaway costs)
  Target CPU:          70% (triggers scaling at 70%)
  Scale Up Period:     0s (immediate)
  Scale Down Period:   300s (5 minutes)
```

#### Monitoring HPA
```bash
# Check HPA status
kubectl get hpa -n default

# Detailed HPA info
kubectl describe hpa bird-api-hpa -n default

# Watch HPA in action
watch kubectl get hpa -n default

# Output example:
NAME                 REFERENCE                   TARGETS         MINPODS   MAXPODS   REPLICAS   AGE
bird-api-hpa         Deployment/bird-api         45%/70%         2         10        2          5m
bird-image-api-hpa   Deployment/bird-image-api   60%/70%         2         10        2          5m
```

### Cluster Autoscaler

#### How It Works

1. **Node Monitoring:**
   - Watches for pods in "Pending" state
   - Checks node utilization every 10 seconds
   - Analyzes if new nodes would help

2. **Scale Up Decision:**
   - If pod can't be scheduled (Pending) → try to add node
   - Creates new node in Auto Scaling Group
   - Node takes ~2-3 minutes to be ready
   - Pod then gets scheduled on new node

3. **Scale Down Decision:**
   - If node utilization < 50% for 10 minutes → consider removal
   - Safely drains pods to other nodes
   - Respects Pod Disruption Budgets
   - Removes underutilized nodes

#### Configuration
```hcl
Cluster Autoscaler:
  Min Nodes:          2 (always maintain 2 for HA)
  Max Nodes:          5 (prevent cost runaway)
  Scale Down Delay:   10 minutes (wait before scaling down)
  Scale Down Enabled: Yes
```

#### Monitoring Cluster Autoscaler
```bash
# Check node count
kubectl get nodes

# Describe nodes
kubectl describe node

# Check Cluster Autoscaler logs
kubectl logs -f deployment/cluster-autoscaler -n kube-system

# Check node status
kubectl top nodes
```

### Real-World Scaling Example

**Scenario: Traffic spike occurs**
```
Time 0:00    - 2 pods running (bird-api), CPU at 30%
Time 0:15    - Traffic increases, CPU hits 75%
Time 1:00    - HPA triggers: scales from 2 -> 3 pods
Time 1:30    - Still high load, CPU at 80%
Time 2:00    - HPA triggers: scales from 3 -> 4 pods
Time 2:30    - CPU drops to 65%, stable
Time 7:30    - Traffic normal, CPU at 40%
Time 8:00    - HPA triggers: scales from 4 -> 3 pods
Time 8:30    - Still stable
Time 13:30   - HPA triggers: scales from 3 -> 2 pods (minimum)

Result: System scaled from 2 -> 4 pods, then back to 2
        Total time: 13 minutes
        Zero downtime during scaling
```

---

## Failure Recovery

### Pod Failure

**What Happens:**
1. Container crashes or health check fails
2. Kubelet detects unhealthy pod (within 30 seconds)
3. Pod automatically restarts
4. If restart fails, Kubernetes removes pod
5. Deployment controller immediately creates replacement

**Recovery Time:** < 15 seconds

**Test It:**
```bash
# Get a pod name
POD_NAME=$(kubectl get pods -l app=bird-api -o jsonpath='{.items[0].metadata.name}')

# Kill the pod
kubectl delete pod $POD_NAME -n default

# Watch replacement
watch kubectl get pods -n default -l app=bird-api

# In ~5-10 seconds, new pod appears with different name
```

### Node Failure

**What Happens:**
1. Node becomes unresponsive (heartbeat stops)
2. Kubernetes marks node as "NotReady" (after 5 minutes)
3. Cluster Autoscaler detects unreachable node
4. Pods on failed node are evicted
5. Deployment controller reschedules pods on healthy nodes
6. Cluster Autoscaler terminates failed node and launches replacement

**Recovery Time:** 5-10 minutes

**Test It:**
```bash
# Cordon a node (mark as unschedulable)
kubectl cordon node-name

# Drain the node (evict all pods)
kubectl drain node-name --ignore-daemonsets

# Watch pods migrate
watch kubectl get pods -o wide -n default

# Uncordon when done
kubectl uncordon node-name
```

### Availability Zone Failure

**What Happens:**
1. All nodes in AZ become unavailable
2. Pods on those nodes are lost
3. Kubernetes reschedules pods on healthy AZ
4. Cluster Autoscaler launches new nodes in healthy AZ
5. System recovers with reduced capacity

**Recovery Time:** < 2 minutes

**Impact:** 50% capacity loss (from 2 nodes to 1 node)

### Service Disruption Handling

**Pod Disruption Budgets (PDB):**
- Ensures at least 1 pod remains running during voluntary disruptions
- Protects against accidental deletion
- Respects maintenance windows

**Example:**
```bash
# Try to delete all pods (respects PDB)
kubectl delete pods -l app=bird-api -n default

# Result: At least 1 pod remains at all times
# Other pods deleted one at a time, allowing replacement
```

### Complete Failure Simulation Test
```bash
#!/bin/bash
# Run the provided failure-simulation.sh script

./failure-simulation.sh

# This tests:
# 1. Pod failure recovery
# 2. HPA recovery
# 3. Service discovery
# 4. Logging
# 5. Monitoring
```

**Expected Results:**
```
- Pod killed -> New pod created in <15s
- Deployment scaled down -> HPA scaled back up
- Services remained available (no downtime)
- Logs captured all events
- CloudWatch alarms triggered
```

---

## Monitoring & Observability

### CloudWatch Overview

CloudWatch is the central monitoring service collecting:
- Metrics from EKS, pods, nodes, services
- Logs from application containers, control plane
- Alarms that trigger on metric thresholds
- Dashboards for visualization

### CloudWatch Dashboards

#### Main Dashboard: `bird-api-overview`
```bash
# Open in AWS Console
https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#dashboards:name=bird-api-overview
```

**Metrics Displayed:**
1. **Cluster Overview**
   - Node count (should be 2-5)
   - Cluster CPU utilization
   - Cluster memory utilization

2. **Pod Metrics**
   - Pod CPU utilization
   - Pod memory utilization
   - Pod restart count

3. **Application Logs**
   - Log entries binned by 5-minute intervals

### CloudWatch Alarms

#### Configured Alarms

| Alarm Name | Metric | Threshold | Action |
|-----------|--------|-----------|--------|
| pod_cpu_high | Pod CPU | > 80% for 2 periods | Alert |
| pod_memory_high | Pod Memory | > 85% for 2 periods | Alert |
| node_not_ready | Node Status | != Ready | Alert |
| pod_restarts_high | Restart Count | > 5 in 5 min | Alert |

#### Viewing Alarms
```bash
# List all alarms
aws cloudwatch describe-alarms --region us-east-1

# Get specific alarm
aws cloudwatch describe-alarms \
  --alarm-names bird-api-pod-cpu-high \
  --region us-east-1

# Get alarm history
aws cloudwatch describe-alarm-history \
  --alarm-name bird-api-pod-cpu-high \
  --region us-east-1
```

### CloudWatch Logs

#### Log Groups
```
/aws/eks/bird-api-cluster/cluster
  - EKS control plane logs
  - Includes: api, audit, authenticator, controllerManager, scheduler

/aws/eks/bird-api-cluster/applications
  - Application logs from pods
  - Retention: 7 days
```

#### Accessing Logs
```bash
# Get logs from bird-api pods
kubectl logs -f deployment/bird-api -n default

# Get logs from all pods
kubectl logs -f -l app=bird-api -n default

# Get previous logs (if pod crashed)
kubectl logs pod-name --previous -n default
```

#### CloudWatch Log Insights Queries

**Query 1: Recent errors**
```sql
fields @timestamp, @message
| filter @message like /ERROR/
| stats count() as error_count by @message
```

**Query 2: Average response times**
```sql
fields response_time
| stats avg(response_time), max(response_time), pct(response_time, 95)
```

**Query 3: Pod restarts**
```sql
fields kubernetes.pod_name, @message
| filter @message like /restarted/
| stats count() as restart_count by kubernetes.pod_name
```

**Query 4: API response codes**
```sql
fields http_status
| stats count() as request_count by http_status
```

### Interpreting Metrics

#### CPU Utilization
```
What it means:
- Shows percentage of CPU cores being used
- Request: 100m = 0.1 cores
- Limit: 500m = 0.5 cores

Interpretation:
- < 30%:  Underutilized, consider reducing requests
- 30-70%: Normal operation
- 70-90%: High load, HPA likely scaling up
- > 90%:  Critical, may indicate issue

Action:
- If consistently > 80%: Increase resource limits
- If spiking to 100%: Check for infinite loops/memory leak
```

#### Memory Utilization
```
What it means:
- Shows percentage of memory being used
- Request: 128Mi = 128 megabytes
- Limit: 512Mi = 512 megabytes

Interpretation:
- < 30%:  Underutilized, could reduce requests
- 30-70%: Normal operation
- 70-85%: High usage, monitor closely
- > 85%:  Critical, pod may be OOMKilled

Action:
- If consistently > 85%: Increase memory limits
- If spiking: Check for memory leak
- Monitor over time for trends
```

#### Node Health
```
What it means:
- Node status should be "Ready"
- "NotReady" means node is unhealthy

Interpretation:
- Ready:     Node is healthy and can accept pods
- NotReady:  Node has issues (network, disk, etc)
- Unknown:   Kubernetes lost contact with node

Action:
- If NotReady for > 5 min: Node will be replaced by Cluster Autoscaler
- Check node logs: kubectl describe node
- Check disk space: kubectl top nodes
```

#### Pod Restart Count
```
What it means:
- Number of times a container has restarted
- Includes crashes, health check failures, manual deletes

Interpretation:
- 0:      Normal, pod never crashed
- 1-2:    Occasional issues, investigate
- > 5:    Serious problem, check logs immediately

Action:
- Check logs: kubectl logs pod-name
- Check events: kubectl describe pod pod-name
- Check resource limits: might be OOMKilled
- Check application errors: review container logs
```

### Setting Up Custom Metrics

**Future enhancement:** You can send custom metrics from your application:
```bash
# Example: Send response time metric
aws cloudwatch put-metric-data \
  --namespace BirdAPI \
  --metric-name ResponseTime \
  --value 245 \
  --unit Milliseconds
```

---

## CloudFront CDN

### What is CloudFront?

CloudFront is AWS's Content Delivery Network (CDN) that:
- Caches responses at edge locations worldwide
- Serves content from location closest to users
- Reduces backend load
- Improves response times

### Your CloudFront Configuration
```
Domain:               d1ltovhjoc76pc.cloudfront.net
Cache TTL:            5 minutes (default)
Compression:          Gzip & Brotli enabled
Protocol:             HTTP (can be upgraded to HTTPS)
Origins:              2 Network Load Balancers
Edge Locations:       200+ worldwide (nearest to you: NBO50)
```

### How Caching Works

**First Request (Cache Miss):**
```
User -> CloudFront Edge -> Load Balancer -> API Pod -> Response -> Cached
Response time: ~200-500ms (depends on backend)
```

**Subsequent Requests (Cache Hit):**
```
User -> CloudFront Edge -> Cached Response
Response time: ~10-50ms (from cache)
```

### Checking Cache Status
```bash
# Check request headers
curl -I http://d1ltovhjoc76pc.cloudfront.net

# Look for:
# X-Cache: Hit from cloudfront      (served from cache)
# X-Cache: Miss from cloudfront     (fetched from origin, then cached)
```

### Cache Invalidation

**When to invalidate cache:**
- After deploying API updates
- When data needs to be fresh immediately
- When cache is stale

**Invalidate all:**
```bash
aws cloudfront create-invalidation \
  --distribution-id E1234ABCD \
  --paths "/*"
```

**Invalidate specific path:**
```bash
aws cloudfront create-invalidation \
  --distribution-id E1234ABCD \
  --paths "/api/birds/*"
```

### CloudFront Logs

CloudFront logs are stored in S3 at: `bird-api-cloudfront-logs-328263827642`

**Example log entry:**
```
2026-01-27  16:54:45  NBO50  245  192.0.2.1  GET  d1ltovhjoc76pc.cloudfront.net  /  200  Hit  123456  0.045
```

**Fields:**
- Date, Time, Edge Location
- Response Time (ms), Client IP
- HTTP Method, Host, URI
- HTTP Status, Cache Status
- Bytes Sent, Time to Get Response

---

## Troubleshooting

### Common Issues & Solutions

#### Issue 1: Pods stuck in "Pending" state

**Symptoms:**
```
NAME              READY   STATUS    RESTARTS   AGE
bird-api-abc123   0/1     Pending   0          5m
```

**Causes:**
- Not enough resources on nodes
- Resource requests too high
- Node selector mismatch

**Solution:**
```bash
# Check pod events
kubectl describe pod bird-api-abc123 -n default

# Check node resources
kubectl top nodes

# Check resource requests
kubectl get pods -o json | grep -A 5 "requests:"

# Scale down the deployment temporarily
kubectl scale deployment bird-api --replicas=1 -n default
```

#### Issue 2: Pods crashing with "CrashLoopBackOff"

**Symptoms:**
```
NAME              READY   STATUS             RESTARTS   AGE
bird-api-abc123   0/1     CrashLoopBackOff   5          2m
```

**Causes:**
- Application error
- Missing environment variables
- Bad configuration

**Solution:**
```bash
# Check logs
kubectl logs bird-api-abc123 -n default

# Check previous logs (before crash)
kubectl logs bird-api-abc123 --previous -n default

# Check events
kubectl describe pod bird-api-abc123 -n default

# Increase log verbosity if needed
kubectl logs bird-api-abc123 -n default --tail=100
```

#### Issue 3: Nodes marked as "NotReady"

**Symptoms:**
```
NAME                           STATUS      ROLES    AGE   VERSION
ip-10-0-101-48.ec2.internal    NotReady    <none>   2h    v1.29.15-eks-ecaa3a6
```

**Causes:**
- Node networking issues
- Disk space full
- Out of memory
- Node crashed

**Solution:**
```bash
# Describe the node
kubectl describe node ip-10-0-101-48.ec2.internal

# Check disk space
ssh to node (via EC2 console)
df -h

# If disk full, check what's taking space
du -sh /var/lib/docker/*

# Cordon the node (stop scheduling new pods)
kubectl cordon ip-10-0-101-48.ec2.internal

# Drain the node (migrate pods)
kubectl drain ip-10-0-101-48.ec2.internal --ignore-daemonsets

# Node will be replaced by Cluster Autoscaler
# Or manually delete: aws ec2 terminate-instances --instance-ids i-xxx
```

#### Issue 4: Load Balancer not getting external IP

**Symptoms:**
```
NAME                   TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
bird-api-service       LoadBalancer   172.20.1.1     pending       80:30322/TCP   5m
```

**Causes:**
- AWS load balancer not created yet (takes 2-3 minutes)
- AWS API rate limiting
- IAM permissions issue

**Solution:**
```bash
# Wait longer (can take 3-5 minutes)
watch kubectl get svc -n default

# Check service events
kubectl describe svc bird-api-service -n default

# Check AWS for load balancer
aws elbv2 describe-load-balancers --region us-east-1

# Check service logs (if custom controller)
kubectl logs -f -n kube-system -l app=...
```

#### Issue 5: High CPU/Memory usage

**Symptoms:**
```
Pod CPU:    95%/70%
Pod Memory: 90%/512Mi
Alarm triggered: pod_cpu_high
```

**Causes:**
- Inefficient code
- Memory leak
- Too many requests
- Infinite loop

**Solution:**
```bash
# Check application logs for errors
kubectl logs -f deployment/bird-api -n default

# Profile the application
# (Depends on your application language/framework)

# Increase resource limits temporarily
kubectl set resources deployment bird-api \
  --limits=cpu=1000m,memory=1Gi \
  -n default

# Monitor closely
watch kubectl top pods -n default

# If still high, may need to optimize application code
```

#### Issue 6: CloudFront returning 503/504 errors

**Symptoms:**
```
curl http://d1ltovhjoc76pc.cloudfront.net
Error: Service Unavailable
```

**Causes:**
- Origin (load balancer) is down
- Network connectivity issue
- CloudFront origin unreachable

**Solution:**
```bash
# Test load balancer directly (bypass CloudFront)
curl http://a5d6bdfc70caf4284aa4829a6909552f-813628650.us-east-1.elb.amazonaws.com

# If that works, issue is CloudFront connectivity
# Check security groups
aws ec2 describe-security-groups --group-ids sg-xxx

# Check route tables
aws ec2 describe-route-tables

# Invalidate CloudFront cache
aws cloudfront create-invalidation --distribution-id E1234ABCD --paths "/*"

# Check CloudFront distribution health
aws cloudfront get-distribution --id E1234ABCD
```

#### Issue 7: Application can't reach external services

**Symptoms:**
```
Error: dial tcp: lookup service.com: server misbehaving
```

**Causes:**
- DNS resolution failing
- Network connectivity issue
- Security group blocking traffic

**Solution:**
```bash
# Check DNS from pod
kubectl exec -it pod-name -n default -- nslookup google.com

# Check internet connectivity
kubectl exec -it pod-name -n default -- ping 8.8.8.8

# Check security group rules
aws ec2 describe-security-groups --group-ids sg-xxx

# Verify NAT Gateway is working
# Check NAT Gateway status in EC2 console

# If NAT not working, check route tables
aws ec2 describe-route-tables --filters Name=vpc-id,Values=vpc-xxx
```

### Getting Help
```bash
# 1. Check pod logs
kubectl logs -f pod-name -n default

# 2. Describe the pod for events
kubectl describe pod pod-name -n default

# 3. Check node status
kubectl describe node node-name

# 4. Check AWS CloudWatch logs
aws logs tail /aws/eks/bird-api-cluster/cluster --follow

# 5. Check deployment status
kubectl describe deployment bird-api -n default

# 6. Get all events in namespace
kubectl get events -n default --sort-by='.lastTimestamp'
```

---

## Cost Analysis

### Monthly Cost Breakdown

| Component | Hourly | Monthly | Notes |
|-----------|--------|---------|-------|
| EKS Control Plane | $0.10 | $73 | Fixed per cluster |
| 2 x t2.medium nodes | $0.0188 | $14 | Lowest tier, ~730 hours/month |
| Network Load Balancer (2x) | $0.006 | $4.30 | Per LB per hour |
| CloudFront | Variable | $5-50 | Depends on data transfer |
| S3 (state + logs) | - | $2 | Minimal for this workload |
| DynamoDB | - | $1 | On-demand, very cheap |
| CloudWatch (logs + alarms) | - | $5 | 7-day retention |
| TOTAL | | $100-140 | Dev environment |

### Cost Optimization Strategies

#### 1. Use Fargate Instead of EC2

**Savings:** ~$30/month
```hcl
# Use EKS Fargate for pods
# No need to manage EC2 instances
# Pay only for pod resources used
```

#### 2. Reduce Log Retention

**Current:** 7 days
**Savings:** Change to 3 days = ~$2/month
```bash
# Update log retention
aws logs put-retention-policy \
  --log-group-name /aws/eks/bird-api-cluster/applications \
  --retention-in-days 3
```

#### 3. Consolidate Load Balancers

**Savings:** ~$4/month (remove 1 LB)

Use ALB Ingress Controller with single ALB instead of 2 NLBs.

#### 4. Use Spot Instances for Non-Critical Workloads

**Savings:** ~60% off EC2 cost = ~$9/month
```hcl
# Mix spot and on-demand instances
# Fargate Spot also available (20% cheaper)
```

#### 5. Schedule Cluster Shutdown During Off-Hours

**Savings:** 30-50% if not 24/7

For development/testing environments that don't need 24/7 operation.

### Cost Monitoring
```bash
# Get estimated monthly costs
aws ce get-cost-and-usage \
  --time-period Start=2026-01-01,End=2026-01-31 \
  --granularity MONTHLY \
  --metrics BlendedCost \
  --group-by Type=DIMENSION,Key=SERVICE

# Monitor costs in AWS Console
https://console.aws.amazon.com/cost-management
```

---

## Maintenance

### Regular Tasks

#### Daily
- Monitor CloudWatch alarms
- Check pod restart counts
- Review error logs

#### Weekly
- Review cost trends
- Check node disk usage
- Verify backups (Terraform state)

#### Monthly
- Review and optimize resource requests
- Analyze performance metrics
- Plan capacity upgrades if needed
- Update dependencies/patches

### Updating Kubernetes Version
```bash
# Check current version
kubectl version --short

# Update in terraform.tfvars
cluster_version = "1.30"  # Update to new version

# Plan the update
terraform plan

# Apply (AWS will handle rolling update)
terraform apply

# Verify
kubectl version --short
```

### Updating Application Images
```bash
# Update in terraform.tfvars
bird_api_image = "bruno74t/bird-api:v.1.0.2"

# Apply changes
terraform apply

# Kubernetes will roll out new pods automatically
kubectl rollout status deployment/bird-api -n default

# Check rollout history
kubectl rollout history deployment/bird-api -n default
```

### Node Maintenance
```bash
# Cordon node (stop new pods from scheduling)
kubectl cordon node-name

# Drain node (migrate pods to other nodes)
kubectl drain node-name --ignore-daemonsets

# Perform maintenance (OS updates, patches, etc)
# Via AWS Systems Manager or EC2 console

# Uncordon node
kubectl uncordon node-name
```

---

## Cleanup

### Destroy All Infrastructure

WARNING: This will delete everything. Make sure you want to do this!
```bash
# 1. First, check what will be destroyed
terraform plan -destroy

# 2. Destroy all resources
terraform destroy

# Type 'yes' to confirm

# This will:
# - Delete EKS cluster (takes ~10 minutes)
# - Terminate EC2 nodes
# - Delete load balancers
# - Remove security groups
# - Delete CloudFront distribution
# - Delete S3 buckets and DynamoDB tables
# - Clear all CloudWatch logs
```

### Partial Cleanup (Keep Some Resources)
```bash
# Delete only certain resources
terraform destroy -target=aws_cloudfront_distribution.bird_api

# Or remove from state without deleting
terraform state rm aws_cloudfront_distribution.bird_api
```

### Clean Up S3 Buckets Manually
```bash
# Empty S3 buckets before deletion (Terraform requirement)
aws s3 rm s3://bird-api-terraform-state-328263827642 --recursive
aws s3 rm s3://bird-api-cloudfront-logs-328263827642 --recursive
```

### Verify Cleanup
```bash
# Check no resources remain
terraform state list

# Should be empty or minimal

# Verify in AWS Console
# - No EKS clusters
# - No EC2 instances
# - No load balancers
# - No CloudFront distributions
# - S3 buckets empty
```

---

## Additional Resources

### Documentation Files

- ARCHITECTURE.md - Detailed architecture with Mermaid diagram
- MONITORING_GUIDE.md - How to use CloudWatch
- RESILIENCE_TEST_RESULTS.md - Failure simulation results

### Terraform Files

All Infrastructure as Code:
- backend.tf - S3 remote state configuration
- variables.tf - Input variables
- terraform.tfvars - Variable values
- vpc.tf - VPC, subnets, security groups
- eks-cluster.tf - EKS cluster and IAM
- eks-node-group.tf - Node group configuration
- kubernetes-provider.tf - Kubernetes deployments and services
- autoscaling.tf - Auto-scaling configuration
- monitoring.tf - CloudWatch setup
- cloudfront.tf - CloudFront CDN
- bucket.tf - S3 and DynamoDB for state
- locals.tf - Local values
- data.tf - Data sources
- output.tf - Outputs

### External Resources

- AWS EKS Documentation: https://docs.aws.amazon.com/eks/
- Kubernetes Documentation: https://kubernetes.io/docs/
- Terraform AWS Provider: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
- CloudFront Documentation: https://docs.aws.amazon.com/cloudfront/
- CloudWatch Documentation: https://docs.aws.amazon.com/cloudwatch/

### Support & Troubleshooting

For issues:
1. Check the Troubleshooting section above
2. Review CloudWatch logs
3. Check Kubernetes events: kubectl get events -n default
4. Review Terraform state: terraform state list

---

## Summary

This Bird API infrastructure demonstrates:

- High Availability - Multi-AZ, load balancing, auto-recovery
- Scalability - HPA scales pods, Cluster Autoscaler scales nodes
- Reliability - Self-healing, pod disruption budgets, health checks
- Observability - CloudWatch monitoring, alarms, dashboards, logs
- Performance - CloudFront CDN caching responses
- Infrastructure as Code - Fully automated with Terraform
- Cost Effective - Auto-scaling prevents overprovisioning
- Production Ready - Best practices implemented throughout

The system can:
- Handle traffic spikes automatically
- Recover from pod/node failures
- Serve users globally via CDN
- Monitor and alert on issues
- Scale efficiently based on demand

---

**Created:** January 27, 2026
**Version:** 1.0
**Maintainer:** DevOps Team
**Last Updated:** January 27, 2026
# resend-api-challenge
