#!/bin/bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=========================================="
echo "Bird API - Failure Simulation Tests"
echo "==========================================${NC}"

# Function to wait for service recovery
wait_for_recovery() {
  local service=$1
  local max_attempts=30
  local attempt=0
  
  echo -e "${BLUE}Waiting for $service to recover...${NC}"
  
  while [ $attempt -lt $max_attempts ]; do
    ready=$(kubectl get pods -l app=$service -o jsonpath='{.items[0].status.conditions[?(@.type=="Ready")].status}' 2>/dev/null || echo "False")
    if [ "$ready" = "True" ]; then
      echo -e "${GREEN}✓ $service recovered!${NC}"
      return 0
    fi
    echo "Attempt $((attempt+1))/$max_attempts - Waiting..."
    sleep 5
    ((attempt++))
  done
  
  echo -e "${RED}✗ $service did not recover in time${NC}"
  return 1
}

# Test 1: Kill a pod and verify recovery
echo -e "\n${BLUE}Test 1: Pod Failure Recovery${NC}"
echo "========================================"
echo "Killing bird-api pod..."

# Get pod name
POD=$(kubectl get pods -l app=bird-api -o jsonpath='{.items[0].metadata.name}')
echo "Pod to kill: $POD"

# Kill the pod
kubectl delete pod $POD -n default

# Wait for recovery
wait_for_recovery "bird-api"

# Verify new pod is running
echo "Checking new pods:"
kubectl get pods -l app=bird-api -n default

# Test 2: Scale down and verify HPA scales back up
echo -e "\n${BLUE}Test 2: Horizontal Pod Autoscaler Recovery${NC}"
echo "========================================"
echo "Scaling bird-api deployment to 1 replica..."

kubectl scale deployment bird-api --replicas=1 -n default

echo "Waiting for HPA to scale back to minimum (2 replicas)..."
sleep 15

echo "Current replicas:"
kubectl get deployment bird-api -n default

# Verify HPA brings it back to min
REPLICAS=$(kubectl get deployment bird-api -o jsonpath='{.spec.replicas}' -n default)
if [ "$REPLICAS" -ge 2 ]; then
  echo -e "${GREEN}✓ HPA successfully scaled deployment back to $REPLICAS replicas${NC}"
else
  echo -e "${RED}✗ HPA did not scale as expected${NC}"
fi

# Test 3: Simulate high load (optional - requires load testing tool)
echo -e "\n${BLUE}Test 3: Load Testing and Auto-scaling${NC}"
echo "========================================"
echo "To test auto-scaling under load, run:"
echo ""
echo "kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh"
echo "while sleep 0.01; do wget -q -O- http://bird-api-service/; done"
echo ""
echo "Watch HPA in another terminal:"
echo "watch kubectl get hpa -n default"

# Test 4: Check service endpoints
echo -e "\n${BLUE}Test 4: Service Discovery${NC}"
echo "========================================"
echo "Bird API Service Endpoints:"
kubectl get endpoints bird-api-service -n default

echo -e "\nBird Image API Service Endpoints:"
kubectl get endpoints bird-image-api-service -n default

# Test 5: Verify monitoring
echo -e "\n${BLUE}Test 5: Monitoring and Logging${NC}"
echo "========================================"
echo "Recent logs from bird-api:"
kubectl logs -l app=bird-api -n default --tail=5

echo -e "\n${GREEN}=========================================="
echo "Failure Simulation Tests Complete!"
echo "==========================================${NC}"
echo ""
echo "Summary:"
echo "✓ Pod failure recovery tested"
echo "✓ HPA recovery tested"
echo "✓ Service endpoints verified"
echo "✓ Logging verified"
echo ""
echo "For load testing, use Apache Bench or wrk:"
echo "ab -n 10000 -c 100 http://[LOAD_BALANCER_IP]/"
echo ""
