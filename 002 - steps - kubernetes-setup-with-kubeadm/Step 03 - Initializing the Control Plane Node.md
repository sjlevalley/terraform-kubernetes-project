# Step 03 - Initializing the Control Plane Node

## Prerequisites
- Go back to the 'Creating a cluster with Kubeadm' page on the Kubernetes documentation.
- Follow the steps in the 'Initializing your control-plane node' section.

## Step 1: Enable IP Forwarding
IP forwarding is required for Kubernetes networking to work properly.

```bash
# 1. Enable IP forwarding temporarily
sudo sysctl net.ipv4.ip_forward=1

# 2. Make it permanent
echo 'net.ipv4.ip_forward=1' | sudo tee -a /etc/sysctl.conf

# 3. Verify IP forwarding is enabled (should return 1)
cat /proc/sys/net/ip_forward
```

## Step 2: Set Proper Hostname
Set a proper hostname to avoid DNS resolution warnings.

```bash
sudo hostnamectl set-hostname master-node
```

## Step 3: Configure Containerd with Systemd Cgroup Driver
This is critical for Kubernetes to work properly with containerd.

```bash
# Create a complete containerd configuration
sudo tee /etc/containerd/config.toml > /dev/null << 'EOF'
version = 2

[plugins]
  [plugins."io.containerd.grpc.v1.cri"]
    [plugins."io.containerd.grpc.v1.cri".cni]
      bin_dir = "/usr/lib/cni"
      conf_dir = "/etc/cni/net.d"
    [plugins."io.containerd.grpc.v1.cri".containerd]
      [plugins."io.containerd.grpc.v1.cri".containerd.runtimes]
        [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
          runtime_type = "io.containerd.runc.v2"
          [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
            SystemdCgroup = true
  [plugins."io.containerd.internal.v1.opt"]
    path = "/var/lib/containerd/opt"
EOF

# Restart containerd to apply the configuration
sudo systemctl restart containerd

# Verify containerd is running
sudo systemctl status containerd
```

## Step 4: Initialize the Kubernetes Cluster
## Must be run on Master node
Use the correct IP addresses from your Terraform deployment.
```bash
sudo kubeadm init --apiserver-advertise-address 172.31.20.247 --pod-network-cidr "10.200.0.0/16" --upload-certs
```

## Troubleshooting Common Issues

### Issue 1: IP Forwarding Not Enabled
**Error:** `[ERROR FileContent--proc-sys-net-ipv4-ip_forward]: /proc/sys/net/ipv4/ip_forward contents are not set to 1`

**Solution:** Follow Step 1 above to enable IP forwarding.

### Issue 2: Hostname Resolution Warning
**Warning:** `[WARNING Hostname]: hostname "ip-172-31-20-247" could not be reached`

**Solution:** Follow Step 2 above to set a proper hostname.

### Issue 3: API Server Not Starting
**Error:** `container.Runtime.Name must be set: invalid argument`

**Solution:** This indicates containerd configuration is missing the runtime type. Follow Step 3 above to create a complete containerd configuration.

### Issue 4: Containerd Service Fails to Start
**Error:** `Job for containerd.service failed because the control process exited with error code`

**Solution:** Check the containerd configuration syntax and ensure proper indentation in the TOML file.

## Step 5: Configure kubectl for Regular User
After successful initialization, configure kubectl to use the cluster.

```bash
# Create .kube directory
mkdir -p $HOME/.kube

# Copy admin configuration
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

# Set proper ownership
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

## Step 6: Deploy Pod Network
You need to deploy a pod network add-on before your cluster can be used.

```bash
# Example: Deploy Calico network (recommended for this setup)
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/calico.yaml
```

## Step 7: Worker Node Join Command
Save this command for joining your worker nodes to the cluster:

```bash
# Join worker nodes to the cluster (run this on each worker node)
kubeadm join 172.31.20.247:6443 --token e3pl9u.qj30eqeff3zs1lxw \
        --discovery-token-ca-cert-hash sha256:7b9a125b8cf6277d6015bbaf09c4bfc1aebc435b85f02f784b69e1011e91e143
```

**Note:** The token and hash values will be different for your cluster. Use the exact values provided by your kubeadm init output.

## Verification Commands
After completing all steps, verify your cluster is working:

```bash
# Check cluster status
kubectl cluster-info

# Check nodes (should show master node as Ready after pod network is deployed)
kubectl get nodes

# Check all pods in kube-system namespace
kubectl get pods -n kube-system
```

## Important Notes
- The `--apiserver-advertise-address` uses the **private IP** of your master node (172.31.20.247)
- The `--pod-network-cidr` uses a /16 subnet (10.200.0.0/16) to accommodate both worker nodes
- The `--upload-certs` flag uploads control-plane certificates to a ConfigMap for easier worker node joining
- **Save the kubeadm join command** - you'll need it for Step 05 (Joining Worker Nodes)
- The master node will show as "NotReady" until a pod network add-on is deployed