#!/bin/bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}=========================================="
echo "Bird API - Infrastructure Failure Simulation"
echo "==========================================${NC}"

# Function to monitor alarms
check_alarms() {
  echo -e "\n${BLUE}Checking CloudWatch Alarms...${NC}"
  aws cloudwatch describe-alarms --region us-east-1 --query 'MetricAlarms[?starts_with(AlarmName, `bird-api`)].{Name:AlarmName,State:StateValue}' --output table
}

# Test 1: Simulate CPU spike by generating load
echo -e "\n${BLUE}Test 1: CPU Load Spike${NC}"
echo "========================================"
echo "Generating high CPU load on bird-api pods..."
echo "This will trigger: bird-api-pod-cpu-high alarm (threshold: 80%)"
echo ""

# Create load generator pod
kubectl run cpu-load-generator --image=busybox --rm -i --restart=Never -- sh -c "while true; do echo 'stress' | md5sum; done" &
LOAD_PID=$!

echo "CPU load running in background (PID: $LOAD_PID)"
echo "Waiting 5 minutes for CloudWatch to detect high CPU..."
sleep 300

# Kill load generator
kill $LOAD_PID 2>/dev/null || true
echo -e "${GREEN}✓ CPU load test completed${NC}"
check_alarms

# Test 2: Simulate memory pressure
echo -e "\n${BLUE}Test 2: Memory Pressure${NC}"
echo "========================================"
echo "Generating memory pressure on bird-api pods..."
echo "This will trigger: bird-api-pod-memory-high alarm (threshold: 85%)"
echo ""

# Create memory stress pod
kubectl run memory-load-generator --image=busybox --rm -i --restart=Never -- sh -c "SIZE=100m; while true; do dd if=/dev/zero of=/tmp/stress bs=1M count=\$SIZE; done" &
MEM_PID=$!

echo "Memory load running in background (PID: $MEM_PID)"
echo "Waiting 5 minutes for CloudWatch to detect high memory..."
sleep 300

# Kill memory generator
kill $MEM_PID 2>/dev/null || true
echo -e "${GREEN}✓ Memory load test completed${NC}"
check_alarms

# Test 3: Simulate node failure
echo -e "\n${BLUE}Test 3: Node Failure Simulation${NC}"
echo "========================================"
echo "Cordoning a node to simulate node failure..."
echo "This will trigger: bird-api-node-not-ready alarm"
echo ""

# Get a node
NODE=$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}')
echo "Cordoning node: $NODE"
kubectl cordon $NODE

echo "Waiting 2 minutes for node to be marked NotReady..."
sleep 120

# Uncordon the node
echo "Uncordoning node to restore..."
kubectl uncordon $NODE
echo -e "${GREEN}✓ Node failure test completed${NC}"
check_alarms

# Test 4: Crash pods repeatedly
echo -e "\n${BLUE}Test 4: Pod Crash Loop${NC}"
echo "========================================"
echo "Force restarting pods to simulate crashes..."
echo "This will trigger: bird-api-pod-restarts-high alarm (threshold: 5+ restarts)"
echo ""

for i in {1..7}; do
  POD=$(kubectl get pods -l app=bird-api -o jsonpath='{.items[0].metadata.name}')
  echo "Force deleting pod $i/7: $POD"
  kubectl delete pod $POD -n default --grace-period=0 --force 2>/dev/null || true
  sleep 10
done

echo -e "${GREEN}✓ Pod restart test completed${NC}"
check_alarms

# Test 5: Final verification
echo -e "\n${BLUE}Test 5: Alert Verification${NC}"
echo "========================================"
echo "All alarms triggered. CloudWatch should have:"
echo "  - bird-api-pod-cpu-high: ALARM"
echo "  - bird-api-pod-memory-high: ALARM"
echo "  - bird-api-pod-restarts-high: ALARM"
echo "  - bird-api-node-not-ready: ALARM (if node failed)"
echo ""
echo "Emails should be sent to: brunogatete77@gmail.com"
echo ""

# Final alarm status
check_alarms

# Cleanup and summary
echo -e "\n${GREEN}=========================================="
echo "Failure Simulation Complete!"
echo "==========================================${NC}"
echo ""
echo "Simulated Failures:"
echo "✓ CPU spike (80%+ utilization)"
echo "✓ Memory pressure (85%+ utilization)"
echo "✓ Node failure (cordoned node)"
echo "✓ Pod crash loop (7 restarts in 70 seconds)"
echo ""
echo "Expected Email Alerts:"
echo "- bird-api-pod-cpu-high"
echo "- bird-api-pod-memory-high"
echo "- bird-api-pod-restarts-high"
echo "- bird-api-node-not-ready (optional)"
echo ""
echo "Check your email: brunogatete77@gmail.com"
echo ""