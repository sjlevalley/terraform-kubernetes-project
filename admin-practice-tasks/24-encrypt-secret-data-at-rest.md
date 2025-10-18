# Encrypt Secret Data at Rest

## Task: CKA - Data Encryption

### Scenario
You need to configure encryption at rest for etcd to protect sensitive data stored in the cluster.

### Tasks
1. **Configure etcd encryption**
   - Create encryption configuration
   - Apply encryption to etcd
   - Verify encryption is working

2. **Test encryption functionality**
   - Create secrets
   - Verify data is encrypted
   - Test secret access

3. **Manage encryption keys**
   - Rotate encryption keys
   - Update encryption configuration
   - Handle key rotation

### Commands to Practice
```bash
# Create encryption configuration
sudo tee /etc/kubernetes/encryption-config.yaml << 'EOF'
apiVersion: apiserver.config.k8s.io/v1
kind: EncryptionConfiguration
resources:
- resources:
  - secrets
  providers:
  - aescbc:
      keys:
      - name: key1
        secret: $(head -c 32 /dev/urandom | base64)
  - identity: {}
EOF

# Generate encryption key
ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)
echo $ENCRYPTION_KEY

# Update encryption config with actual key
sudo sed -i "s/\$(head -c 32 \/dev\/urandom | base64)/$ENCRYPTION_KEY/" /etc/kubernetes/encryption-config.yaml

# Verify encryption config
sudo cat /etc/kubernetes/encryption-config.yaml

# Update kube-apiserver manifest
sudo cp /etc/kubernetes/manifests/kube-apiserver.yaml /etc/kubernetes/manifests/kube-apiserver.yaml.backup

# Add encryption config to kube-apiserver
sudo sed -i '/- --tls-private-key-file=\/etc\/kubernetes\/pki\/apiserver.key/a\    - --encryption-provider-config=/etc/kubernetes/encryption-config.yaml' /etc/kubernetes/manifests/kube-apiserver.yaml

# Add volume mount for encryption config
sudo sed -i '/- mountPath: \/etc\/kubernetes\/pki/a\    - name: encryption-config\n      mountPath: /etc/kubernetes/encryption-config.yaml\n      readOnly: true' /etc/kubernetes/manifests/kube-apiserver.yaml

# Add volume for encryption config
sudo sed -i '/- name: pki/a\  - name: encryption-config\n    hostPath:\n      path: /etc/kubernetes/encryption-config.yaml\n      type: File' /etc/kubernetes/manifests/kube-apiserver.yaml

# Restart kube-apiserver
sudo systemctl restart kubelet

# Wait for kube-apiserver to be ready
kubectl get pods -n kube-system | grep kube-apiserver

# Create test secret
kubectl create secret generic test-secret --from-literal=password=secret123

# Verify secret exists
kubectl get secret test-secret -o yaml

# Check if secret is encrypted in etcd
sudo ETCDCTL_API=3 etcdctl get /registry/secrets/default/test-secret \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key

# Create more secrets to test
kubectl create secret generic db-secret --from-literal=username=admin --from-literal=password=dbpass123
kubectl create secret generic api-key --from-literal=key=sk-1234567890abcdef

# Verify secrets are accessible
kubectl get secret test-secret -o jsonpath='{.data.password}' | base64 -d
kubectl get secret db-secret -o jsonpath='{.data.username}' | base64 -d

# Create encryption key rotation script
sudo tee /usr/local/bin/rotate-encryption-key.sh << 'EOF'
#!/bin/bash
# Generate new encryption key
NEW_KEY=$(head -c 32 /dev/urandom | base64)
echo "New encryption key: $NEW_KEY"

# Create new encryption config
cat > /tmp/new-encryption-config.yaml << EOL
apiVersion: apiserver.config.k8s.io/v1
kind: EncryptionConfiguration
resources:
- resources:
  - secrets
  providers:
  - aescbc:
      keys:
      - name: key2
        secret: $NEW_KEY
      - name: key1
        secret: $(grep -A 1 "name: key1" /etc/kubernetes/encryption-config.yaml | grep secret | awk '{print $2}')
  - identity: {}
EOL

# Backup current config
sudo cp /etc/kubernetes/encryption-config.yaml /etc/kubernetes/encryption-config.yaml.backup

# Apply new config
sudo cp /tmp/new-encryption-config.yaml /etc/kubernetes/encryption-config.yaml

# Restart kube-apiserver
sudo systemctl restart kubelet

echo "Encryption key rotated successfully"
EOF

# Make script executable
sudo chmod +x /usr/local/bin/rotate-encryption-key.sh

# Test key rotation
sudo /usr/local/bin/rotate-encryption-key.sh

# Verify secrets are still accessible after rotation
kubectl get secret test-secret
kubectl get secret db-secret

# Check encryption status
kubectl get --raw /api/v1/secrets | jq '.items[0].data'

# Create script to verify encryption
sudo tee /usr/local/bin/verify-encryption.sh << 'EOF'
#!/bin/bash
echo "Checking if secrets are encrypted in etcd..."

# Get all secrets
SECRETS=$(kubectl get secrets -o name)

for secret in $SECRETS; do
    secret_name=$(echo $secret | cut -d'/' -f2)
    echo "Checking secret: $secret_name"
    
    # Check if secret is encrypted in etcd
    etcd_output=$(sudo ETCDCTL_API=3 etcdctl get /registry/secrets/default/$secret_name \
      --endpoints=https://127.0.0.1:2379 \
      --cacert=/etc/kubernetes/pki/etcd/ca.crt \
      --cert=/etc/kubernetes/pki/etcd/server.crt \
      --key=/etc/kubernetes/pki/etcd/server.key 2>/dev/null)
    
    if echo "$etcd_output" | grep -q "k8s:enc:aescbc:v1:key1"; then
        echo "  ✓ Secret is encrypted"
    else
        echo "  ✗ Secret is not encrypted"
    fi
done
EOF

# Make script executable
sudo chmod +x /usr/local/bin/verify-encryption.sh

# Run verification
sudo /usr/local/bin/verify-encryption.sh
```

### Expected Outcomes
- etcd encryption configured successfully
- Secrets encrypted at rest
- Encryption key rotation working
- Secret access still functional
- Encryption verification successful
