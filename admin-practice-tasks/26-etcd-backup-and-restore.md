# etcd Backup and Restore

## Task: CKA - etcd Operations

### Scenario
You need to backup and restore etcd data to ensure cluster data safety and disaster recovery.

### Tasks
1. **Create etcd backup**
   - Backup etcd data to file
   - Verify backup integrity
   - Schedule regular backups

2. **Restore etcd from backup**
   - Stop etcd service
   - Restore from backup file
   - Restart etcd service

3. **Test backup and restore process**
   - Create test data
   - Perform backup
   - Restore and verify data

### Commands to Practice
```bash
# Check etcd status
sudo systemctl status etcd

# Find etcd data directory
sudo find /var/lib -name "member" -type d 2>/dev/null

# Create etcd backup
sudo ETCDCTL_API=3 etcdctl snapshot save /tmp/etcd-backup-$(date +%Y%m%d-%H%M%S).db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key

# Verify backup
sudo ETCDCTL_API=3 etcdctl snapshot status /tmp/etcd-backup-*.db \
  --write-out=table

# Create test data
kubectl create configmap test-backup --from-literal=test=backup-data
kubectl get configmap test-backup

# Create backup with test data
sudo ETCDCTL_API=3 etcdctl snapshot save /tmp/etcd-backup-with-test.db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key

# Stop kubelet and etcd
sudo systemctl stop kubelet
sudo systemctl stop etcd

# Remove existing etcd data
sudo rm -rf /var/lib/etcd/member

# Restore from backup
sudo ETCDCTL_API=3 etcdctl snapshot restore /tmp/etcd-backup-with-test.db \
  --data-dir=/var/lib/etcd \
  --name=master \
  --initial-cluster=master=https://127.0.0.1:2380 \
  --initial-cluster-token=etcd-cluster-1 \
  --initial-advertise-peer-urls=https://127.0.0.1:2380

# Set proper ownership
sudo chown -R etcd:etcd /var/lib/etcd

# Start etcd and kubelet
sudo systemctl start etcd
sudo systemctl start kubelet

# Wait for etcd to be ready
sudo systemctl status etcd

# Verify cluster is working
kubectl get nodes
kubectl get pods --all-namespaces

# Verify test data is restored
kubectl get configmap test-backup

# Create automated backup script
sudo tee /usr/local/bin/etcd-backup.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/opt/etcd-backups"
DATE=$(date +%Y%m%d-%H%M%S)
BACKUP_FILE="$BACKUP_DIR/etcd-backup-$DATE.db"

mkdir -p $BACKUP_DIR

ETCDCTL_API=3 etcdctl snapshot save $BACKUP_FILE \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key

# Keep only last 7 days of backups
find $BACKUP_DIR -name "etcd-backup-*.db" -mtime +7 -delete

echo "Backup completed: $BACKUP_FILE"
EOF

# Make script executable
sudo chmod +x /usr/local/bin/etcd-backup.sh

# Test backup script
sudo /usr/local/bin/etcd-backup.sh

# Create cron job for daily backups
echo "0 2 * * * /usr/local/bin/etcd-backup.sh" | sudo crontab -

# Check cron job
sudo crontab -l

# List backup files
sudo ls -la /opt/etcd-backups/

# Test restore from automated backup
sudo ETCDCTL_API=3 etcdctl snapshot status /opt/etcd-backups/etcd-backup-*.db \
  --write-out=table
```

### Expected Outcomes
- etcd backup created successfully
- Backup integrity verified
- etcd restored from backup
- Cluster functionality restored
- Automated backup system configured
