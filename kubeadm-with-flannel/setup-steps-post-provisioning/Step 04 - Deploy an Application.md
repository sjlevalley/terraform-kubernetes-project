# Step 04 - Deploy an Application (Voting App)

**Prerequisites:** 
- Step 01, Step 02, and Step 03 must be completed first
- Kubernetes cluster is running and healthy
- kubectl is configured on the master node
- **Important**: Ensure Step 03's "Setup Flannel Plugin on ALL Nodes" section was completed on all nodes (master, node-0, and node-1)

## Step 1: Copy Voting App to Master Node

***RUN FROM YOUR LOCAL MACHINE***
```bash
# Navigate to the project root directory first
cd

# RUN FROM TERRAFORM DIRECTORY Copy the voting-app directory to the master node
scp -i "k8s-key.pem" -r "../applications/voting-app" admin@35.172.214.252:~/

# Verify the files were copied
ssh -i "k8s-key.pem" admin@35.172.214.252 "ls -la ~/voting-app/"
```

**Important:** Make sure you're in the project root directory (`terraform-kubernetes-project`) when running the SCP command, as the path is relative to that location.

## Step 2: Deploy the Voting Application

***RUN ON MASTER NODE***
```bash
# SSH into the master node
ssh -i "kubeadm-with-flannel/terraform/k8s-key.pem" admin@35.172.214.252

# Navigate to the voting-app directory and apply the project files
cd ~/voting-app && kubectl apply -f .


# Check deployment status
kubectl get pods
kubectl get services
```

## Step 3: Verify Deployment

***RUN ON MASTER NODE***
```bash
# Wait for all pods to be ready (this may take a few minutes)
kubectl get pods -w

# Check all services
kubectl get services

# Check if NodePort services are accessible
kubectl get nodes -o wide
```

## Step 4: Test the Application

### Access the Voting App:
- **Vote App**: `http://35.172.214.252:30001`
- **Result App**: `http://35.172.214.252:30002`

### Test Steps:
1. **Vote**: Go to the vote app and click on "Cats" or "Dogs"
2. **View Results**: Go to the result app to see the voting results
3. **Check Logs**: Monitor the worker processing votes

## Step 5: Monitor and Troubleshoot

***RUN ON MASTER NODE***
```bash
# Check pod logs
kubectl logs -f deployment/vote
kubectl logs -f deployment/result
kubectl logs -f deployment/worker

# Check pod status
kubectl describe pod <pod-name>

# Check service endpoints
kubectl get endpoints

# Check events
kubectl get events --sort-by=.metadata.creationTimestamp
```

## Troubleshooting Common Issues

### Issue 1: Pods Stuck in Pending State
```bash
# Check node resources
kubectl describe nodes

# Check if images are being pulled
kubectl describe pod <pod-name>
```

### Issue 2: Cannot Access Application from Browser
```bash
# Check if NodePort services are running
kubectl get services

# Check if ports are open in security groups
# Ensure ports 30001 and 30002 are open in AWS security group

# Test connectivity from master node
curl http://localhost:30001
curl http://localhost:30002
```

### Issue 3: Database Connection Issues
```bash
# Check database pods
kubectl get pods | grep -E "(redis|db)"

# Check database logs
kubectl logs deployment/redis
kubectl logs deployment/db

# Test database connectivity
kubectl exec -it deployment/redis -- redis-cli ping
```

## Useful Commands

```bash
# Scale the vote app
kubectl scale deployment vote --replicas=3

# Check resource usage
kubectl top pods
kubectl top nodes

# Delete the application
kubectl delete -f .

# Restart a deployment
kubectl rollout restart deployment/vote
```

## Expected Results

After successful deployment, you should see:

- **5 pods running**: vote, result, worker, redis, db
- **4 services**: vote (NodePort 30001), result (NodePort 30002), redis, db
- **Vote app accessible** at `http://35.172.214.252:30001`
- **Result app accessible** at `http://35.172.214.252:30002`
- **Voting functionality working** - votes are processed and results are displayed

## Clean Up

To remove the application:

```bash
# Delete all resources
kubectl delete -f .

# Verify cleanup
kubectl get pods
kubectl get services
```

## Security Group Configuration

Ensure your AWS security group allows inbound traffic on:
- **Port 30001** (Vote App)
- **Port 30002** (Result App)
- **Port 4789 UDP** (VXLAN for Flannel CNI) - **Not needed for Calico CNI**

**Security Group Rules:**
```
Type: Custom TCP
Port: 30001-30002
Source: 0.0.0.0/0
Description: Voting App NodePort Services

Type: Custom UDP
Port: 4789
Source: 172.31.0.0/16
Description: VXLAN for Flannel CNI (not needed for Calico)
```

**Important:** Since you're using Calico CNI (not Flannel), the VXLAN UDP 4789 rule is not required. Calico uses BGP routing instead of VXLAN overlay networking.

## Troubleshooting NodePort Access Issues

### TX Checksum Offloading Issue (Ubuntu 22.04 + Flannel)

If external browser access to NodePort services hangs despite local access working, this is likely due to TX checksum offloading on the flannel.1 interface. This is a known issue with Flannel VXLAN on Ubuntu 22.04 in AWS EC2 environments.

**Symptoms:**
- Local NodePort access works: `curl http://localhost:30001`
- External browser access hangs or times out
- All pods are running and healthy
- Security group rules are correct

**Solution - Apply Persistent TX Checksum Fix:**

1. **Apply the fix to all nodes:**
   ```bash
   # Make scripts executable
   chmod +x fix-flannel-tx-checksum.sh apply-persistent-tx-checksum-fix.sh
   
   # Apply persistent fix to all nodes
   ./apply-persistent-tx-checksum-fix.sh
   ```

2. **Verify the fix is working:**
   ```bash
   # Check service status on any node
   ssh -i k8s-key.pem admin@3.82.57.51 'sudo systemctl status flannel-tx-checksum-fix.service'
   
   # Verify TX checksum is disabled
   ssh -i k8s-key.pem admin@3.82.57.51 'ethtool -k flannel.1 | grep tx-checksumming'
   
   # Test external access
   curl http://3.82.57.51:30001
   ```

3. **Run verification script:**
   ```bash
   chmod +x verify-nodeport-access.sh
   ./verify-nodeport-access.sh
   ```

**What the fix does:**
- Creates a systemd service that automatically disables TX checksum offloading on flannel.1
- Runs after flanneld service starts
- Persists across reboots
- Applies to all nodes in the cluster

**Alternative solutions if the fix doesn't work:**
1. Switch to Calico CNI plugin
2. Try kube-proxy in IPVS mode
3. Check if VXLAN security group rule was actually applied