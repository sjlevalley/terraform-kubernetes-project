# Upgrade Kubernetes Version

## Task: CKA - Cluster Upgrade Management

### Scenario
You need to upgrade your Kubernetes cluster to a newer version while maintaining service availability.

### Tasks
1. **Plan cluster upgrade**
   - Check current cluster version
   - Identify upgrade path
   - Plan upgrade strategy

2. **Upgrade control plane**
   - Upgrade kubeadm
   - Upgrade control plane components
   - Verify control plane health

3. **Upgrade worker nodes**
   - Drain worker nodes
   - Upgrade kubelet and kubeadm
   - Rejoin nodes to cluster

### Commands to Practice
```bash
# Check current cluster version
kubectl version --short
kubeadm version

# Check upgrade plan
kubeadm upgrade plan

# Check available versions
apt list --upgradable | grep kube

# Backup cluster state
kubectl get all --all-namespaces -o yaml > cluster-backup.yaml

# Backup etcd
sudo ETCDCTL_API=3 etcdctl snapshot save /tmp/etcd-backup-$(date +%Y%m%d-%H%M%S).db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key

# Upgrade kubeadm on control plane
sudo apt-mark unhold kubeadm
sudo apt-get update
sudo apt-get install -y kubeadm=1.28.0-00
sudo apt-mark hold kubeadm

# Verify kubeadm version
kubeadm version

# Upgrade control plane
sudo kubeadm upgrade apply v1.28.0

# Verify control plane upgrade
kubectl version --short

# Upgrade kubelet and kubectl on control plane
sudo apt-mark unhold kubelet kubectl
sudo apt-get update
sudo apt-get install -y kubelet=1.28.0-00 kubectl=1.28.0-00
sudo apt-mark hold kubelet kubectl

# Restart kubelet
sudo systemctl daemon-reload
sudo systemctl restart kubelet

# Verify control plane is healthy
kubectl get nodes
kubectl get pods --all-namespaces

# Upgrade worker nodes (repeat for each worker)
# First, drain the node
kubectl drain worker-node-1 --ignore-daemonsets --delete-emptydir-data

# SSH to worker node and upgrade kubeadm
ssh admin@worker-node-1
sudo apt-mark unhold kubeadm
sudo apt-get update
sudo apt-get install -y kubeadm=1.28.0-00
sudo apt-mark hold kubeadm

# Upgrade kubelet and kubectl on worker
sudo apt-mark unhold kubelet kubectl
sudo apt-get update
sudo apt-get install -y kubelet=1.28.0-00 kubectl=1.28.0-00
sudo apt-mark hold kubelet kubectl

# Upgrade node configuration
sudo kubeadm upgrade node

# Restart kubelet
sudo systemctl daemon-reload
sudo systemctl restart kubelet

# Exit SSH and uncordon the node
exit
kubectl uncordon worker-node-1

# Verify worker node is ready
kubectl get nodes

# Repeat for other worker nodes
kubectl drain worker-node-2 --ignore-daemonsets --delete-emptydir-data
# ... upgrade process for worker-node-2
kubectl uncordon worker-node-2

# Verify cluster upgrade
kubectl get nodes
kubectl version --short

# Check cluster health
kubectl get pods --all-namespaces
kubectl get svc --all-namespaces

# Test application functionality
kubectl run test-pod --image=nginx --restart=Never
kubectl get pods
kubectl delete pod test-pod

# Check for deprecated APIs
kubectl get --raw /api/v1 | grep -i deprecated

# Update cluster configuration
kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: kubeadm-config
  namespace: kube-system
data:
  ClusterConfiguration: |
    apiVersion: kubeadm.k8s.io/v1beta3
    kind: ClusterConfiguration
    kubernetesVersion: v1.28.0
    controlPlaneEndpoint: "172.31.22.38:6443"
    clusterName: kubernetes
    networking:
      serviceSubnet: "10.96.0.0/12"
      podSubnet: "10.244.0.0/16"
      dnsDomain: "cluster.local"
EOF

# Verify upgrade completion
kubectl get nodes -o wide
kubectl get pods --all-namespaces | grep -v Running

# Check system pods
kubectl get pods -n kube-system

# Test cluster functionality
kubectl create deployment test-app --image=nginx --replicas=3
kubectl expose deployment test-app --port=80 --type=NodePort
kubectl get svc test-app

# Clean up test resources
kubectl delete deployment test-app
kubectl delete service test-app

# Create upgrade verification script
sudo tee /usr/local/bin/verify-upgrade.sh << 'EOF'
#!/bin/bash
echo "=== Kubernetes Upgrade Verification ==="

# Check versions
echo "Kubernetes Version:"
kubectl version --short

# Check node status
echo -e "\nNode Status:"
kubectl get nodes

# Check system pods
echo -e "\nSystem Pods:"
kubectl get pods -n kube-system

# Check cluster health
echo -e "\nCluster Health:"
kubectl get pods --all-namespaces | grep -v Running | grep -v Completed

# Check events
echo -e "\nRecent Events:"
kubectl get events --sort-by=.metadata.creationTimestamp | tail -5

echo -e "\nUpgrade verification completed"
EOF

# Make script executable
sudo chmod +x /usr/local/bin/verify-upgrade.sh

# Run verification
/usr/local/bin/verify-upgrade.sh

# Create rollback plan
sudo tee /usr/local/bin/rollback-upgrade.sh << 'EOF'
#!/bin/bash
echo "=== Kubernetes Upgrade Rollback ==="

# Restore etcd backup
echo "Restoring etcd backup..."
sudo systemctl stop kubelet
sudo systemctl stop etcd

# Remove current etcd data
sudo rm -rf /var/lib/etcd/member

# Restore from backup
sudo ETCDCTL_API=3 etcdctl snapshot restore /tmp/etcd-backup-*.db \
  --data-dir=/var/lib/etcd \
  --name=master \
  --initial-cluster=master=https://127.0.0.1:2380 \
  --initial-cluster-token=etcd-cluster-1 \
  --initial-advertise-peer-urls=https://127.0.0.1:2380

# Set proper ownership
sudo chown -R etcd:etcd /var/lib/etcd

# Start services
sudo systemctl start etcd
sudo systemctl start kubelet

echo "Rollback completed"
EOF

# Make rollback script executable
sudo chmod +x /usr/local/bin/rollback-upgrade.sh
```

### Expected Outcomes
- Cluster upgraded to target version
- All nodes showing correct version
- System pods running successfully
- Application functionality verified
- Rollback plan prepared
