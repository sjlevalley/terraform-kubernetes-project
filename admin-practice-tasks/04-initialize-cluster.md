# Initialize Kubernetes Cluster

## Task: Initialize Control Plane and Join Worker Nodes

### Scenario
You need to initialize a new Kubernetes cluster and join worker nodes to it.

### Tasks
1. **Initialize control plane**
   - Run kubeadm init
   - Configure kubectl
   - Save join command

2. **Join worker nodes**
   - Use join command on worker nodes
   - Verify nodes are ready
   - Check cluster status

3. **Configure cluster networking**
   - Install CNI plugin
   - Verify pod-to-pod communication
   - Test cluster functionality

### Commands to Practice
```bash
# Initialize control plane
sudo kubeadm init --apiserver-advertise-address=<master-ip> --pod-network-cidr=10.244.0.0/16

# Configure kubectl for regular user
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Save join command (from init output)
# Example: kubeadm join <master-ip>:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>

# On worker nodes - join cluster
sudo kubeadm join <master-ip>:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>

# Check cluster status
kubectl get nodes
kubectl get pods --all-namespaces

# Install CNI plugin (Flannel example)
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

# Wait for nodes to be ready
kubectl get nodes

# Test cluster functionality
kubectl run test-pod --image=nginx --restart=Never
kubectl get pods
kubectl delete pod test-pod
```

### Expected Outcomes
- Control plane initialized successfully
- Worker nodes joined and ready
- CNI plugin installed and working
- Cluster fully functional
