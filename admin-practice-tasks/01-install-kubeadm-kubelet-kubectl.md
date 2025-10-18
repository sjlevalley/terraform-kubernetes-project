# Install kubeadm, kubelet, and kubectl

## Task: Install Kubernetes Components

### Scenario
You need to install the core Kubernetes components (kubeadm, kubelet, kubectl) on your nodes.

### Tasks
1. **Install Kubernetes packages**
   - Add Kubernetes repository
   - Install kubeadm, kubelet, kubectl
   - Configure package versions

2. **Configure kubelet**
   - Set up kubelet service
   - Configure systemd integration
   - Start and enable kubelet

3. **Verify installation**
   - Check component versions
   - Test kubectl functionality
   - Verify kubelet status

### Commands to Practice
```bash
# Update package index
sudo apt-get update

# Install required packages
sudo apt-get install -y apt-transport-https ca-certificates curl

# Add Kubernetes GPG key
sudo curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg

# Add Kubernetes repository
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Update package index
sudo apt-get update

# Install Kubernetes components
sudo apt-get install -y kubelet kubeadm kubectl

# Pin versions to prevent automatic updates
sudo apt-mark hold kubelet kubeadm kubectl

# Configure kubelet
sudo systemctl daemon-reload
sudo systemctl enable kubelet

# Check versions
kubeadm version
kubectl version --client
kubelet --version

# Check kubelet status
sudo systemctl status kubelet

# Test kubectl (will fail until cluster is initialized)
kubectl version
```

### Expected Outcomes
- Kubernetes components installed successfully
- Kubelet service enabled and running
- Component versions verified
- Ready for cluster initialization
