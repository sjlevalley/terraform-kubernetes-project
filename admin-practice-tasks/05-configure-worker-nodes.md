# Configure Worker Nodes

## Task: Set Up and Manage Worker Nodes

### Scenario
You need to add new worker nodes to your cluster and configure them properly.

### Tasks
1. **Prepare worker node**
   - Install container runtime (containerd/docker)
   - Install kubelet and kubeadm
   - Configure system requirements

2. **Join worker node to cluster**
   - Generate join token from master
   - Join worker node to cluster
   - Verify node is ready

3. **Configure node resources**
   - Set up node labels and taints
   - Configure resource limits
   - Test pod scheduling

### Commands to Practice
```bash
# On master node - generate join token
kubeadm token create --print-join-command

# On worker node - join cluster
sudo kubeadm join <master-ip>:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>

# Verify node joined
kubectl get nodes

# Add node labels
kubectl label node <node-name> node-type=worker
kubectl label node <node-name> environment=production

# Add node taint
kubectl taint node <node-name> key=value:NoSchedule

# Remove node taint
kubectl taint node <node-name> key=value:NoSchedule-

# Check node resources
kubectl describe node <node-name>
kubectl top nodes

# Test pod scheduling
kubectl run test-pod --image=nginx --restart=Never
kubectl get pods -o wide
```

### Expected Outcomes
- Worker node successfully joined cluster
- Node shows as Ready state
- Pods can be scheduled on worker node
- Node labels and taints configured correctly
