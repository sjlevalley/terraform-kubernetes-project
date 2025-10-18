# Install CNI Plugin

## Task: Install and Configure CNI Plugin

### Scenario
You need to install a CNI (Container Network Interface) plugin to enable pod-to-pod communication.

### Tasks
1. **Install CNI plugin**
   - Choose between Flannel, Calico, or Weave Net
   - Apply CNI plugin manifests
   - Verify installation

2. **Configure network policies**
   - Set up network segmentation
   - Test pod-to-pod communication
   - Verify DNS resolution

3. **Troubleshoot network issues**
   - Debug connectivity problems
   - Check CNI plugin logs
   - Verify network configuration

### Commands to Practice
```bash
# Install Flannel CNI
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

# Install Calico CNI
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

# Install Weave Net CNI
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

# Verify CNI installation
kubectl get pods -n kube-system | grep -E "(flannel|calico|weave)"

# Check node network status
kubectl get nodes -o wide

# Test pod-to-pod communication
kubectl run test-pod-1 --image=nginx --restart=Never
kubectl run test-pod-2 --image=nginx --restart=Never

# Get pod IPs
kubectl get pods -o wide

# Test connectivity
kubectl exec -it test-pod-1 -- ping <test-pod-2-ip>

# Test DNS resolution
kubectl exec -it test-pod-1 -- nslookup kubernetes.default.svc.cluster.local

# Check CNI logs
kubectl logs -n kube-system -l app=flannel
```

### Expected Outcomes
- CNI plugin installed and running
- All nodes show as Ready
- Pod-to-pod communication working
- DNS resolution functional
