# Step 03 - Initializing the Control Plane Node


## Step 1: Enable IP Forwarding - Needs to be run on All Nodes
IP forwarding is required for Kubernetes networking to work properly.

*****RUN ON ALL NODES*****
```bash
{
sudo sysctl net.ipv4.ip_forward=1 # Enable IP forwarding temporarily
echo 'net.ipv4.ip_forward=1' | sudo tee -a /etc/sysctl.conf # Make it permanent
cat /proc/sys/net/ipv4/ip_forward # Verify IP forwarding is enabled (should return 1)
}
```

## Step 2: Set Proper Hostname On Each Node
Set a proper hostname to avoid DNS resolution warnings.

```bash
sudo hostnamectl set-hostname master
# sudo hostnamectl set-hostname node-0
# sudo hostnamectl set-hostname node-1
```

## Step 3: Initialize the Kubernetes Cluster

***ONLY RUN ON MASTER NODE***
Use the correct IP addresses from your Terraform deployment.
```bash
sudo kubeadm init --apiserver-advertise-address <MASTER_NODE_PRIVATE_IP> --pod-network-cidr "10.244.0.0/16" --upload-certs
```



## Step 4: Configure kubectl for Regular User
After successful initialization, configure kubectl to use the cluster.

***ONLY RUN ON MASTER NODE***
```bash
{
# Create .kube directory
mkdir -p $HOME/.kube

# Copy admin configuration
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

# Set proper ownership
sudo chown $(id -u):$(id -g) $HOME/.kube/config
}
```

## Step 5: Deploy Pod Network
You need to deploy a pod network add-on before your cluster can be used.

```bash
# Example: Deploy Flannel network
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

# Example: Deploy Calico network (recommended for this setup)
# kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/calico.yaml

```

## Step 6: Worker Node Join Command
Save this command for joining your worker nodes to the cluster:

```bash
# Join worker nodes to the cluster (run this on each worker node)
sudo kubeadm join 172.31.19.113:6443 --token <TOKEN> \
        --discovery-token-ca-cert-hash sha256:<HASH>
```

**Note:** The token and hash values will be different for your cluster. Use the exact values provided by your kubeadm init output.











## Troubleshooting Common Issues

### Issue 1: IP Forwarding Not Enabled
**Error:** `[ERROR FileContent--proc-sys-net-ipv4-ip_forward]: /proc/sys/net/ipv4/ip_forward contents are not set to 1`

**Solution:** Follow Step 1 above to enable IP forwarding.

### Issue 2: Hostname Resolution Warning
**Warning:** `[WARNING Hostname]: hostname "ip-172-31-20-247" could not be reached`

**Solution:** Follow Step 2 above to set a proper hostname.

### Issue 3: API Server Not Starting
**Error:** `container.Runtime.Name must be set: invalid argument`

**Solution:** This indicates containerd configuration is missing the runtime type. Follow Step 02 (Install Container Runtime) to create a complete containerd configuration.

### Issue 4: Containerd Service Fails to Start
**Error:** `Job for containerd.service failed because the control process exited with error code`

**Solution:** Check the containerd configuration syntax and ensure proper indentation in the TOML file.

### Issue 5: Duplicate Join Attempt
**Error:** `[ERROR FileAvailable--etc-kubernetes-kubelet.conf]: /etc/kubernetes/kubelet.conf already exists`

**Solution:** This happens when a node has been partially joined before. Reset the node and try again:

```bash
# 1. Reset kubeadm on this node
sudo kubeadm reset --force

# 2. Stop and disable kubelet
sudo systemctl stop kubelet
sudo systemctl disable kubelet

# 3. Clean up any remaining files
sudo rm -rf /etc/kubernetes/
sudo rm -rf /var/lib/kubelet/
sudo rm -rf /var/lib/etcd/

# 4. Now try the join command again
sudo kubeadm join 172.31.19.113:6443 --token <TOKEN> \
        --discovery-token-ca-cert-hash sha256:<HASH>
```

### Issue 6: Expired Join Token
**Error:** `[ERROR TokenInvalid]: token is invalid due to time`

**Solution:** Generate a new join token from the master node:

```bash
# On the master node, generate a new join token
sudo kubeadm token create --print-join-command
```

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
- The `--apiserver-advertise-address` uses the **private IP** of your master node (172.31.19.113)
- The `--pod-network-cidr` uses a /16 subnet (10.244.0.0/16) to accommodate both worker nodes
- The `--upload-certs` flag uploads control-plane certificates to a ConfigMap for easier worker node joining
- **Save the kubeadm join command** - you'll need it for Step 05 (Joining Worker Nodes)
- The master node will show as "NotReady" until a pod network add-on is deployed