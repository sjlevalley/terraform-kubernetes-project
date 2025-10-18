# Create Persistent Volumes

## Task: CKAD - Persistent Storage Management

### Scenario
You need to create and manage persistent storage for stateful applications.

### Tasks
1. **Create PersistentVolumes**
   - Create local storage PV
   - Create network storage PV
   - Configure storage classes

2. **Create PersistentVolumeClaims**
   - Request storage for applications
   - Configure access modes
   - Bind PVCs to PVs

3. **Use persistent storage in pods**
   - Mount PVCs in pods
   - Test data persistence
   - Verify storage functionality

### Commands to Practice
```bash
# Create local PersistentVolume
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: local-pv
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: local-storage
  hostPath:
    path: /mnt/data
EOF

# Create network PersistentVolume
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nfs-pv
spec:
  capacity:
    storage: 20Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  storageClassName: nfs-storage
  nfs:
    server: nfs-server.example.com
    path: /exports/data
EOF

# Create StorageClass
kubectl apply -f - <<EOF
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-ssd
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp3
  fsType: ext4
reclaimPolicy: Delete
allowVolumeExpansion: true
EOF

# Create PersistentVolumeClaim
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: app-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
  storageClassName: fast-ssd
EOF

# Create pod with persistent storage
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
spec:
  containers:
  - name: app
    image: nginx
    volumeMounts:
    - name: app-storage
      mountPath: /var/www/html
  volumes:
  - name: app-storage
    persistentVolumeClaim:
      claimName: app-pvc
EOF

# Check PV and PVC status
kubectl get pv
kubectl get pvc
kubectl describe pv local-pv
kubectl describe pvc app-pvc

# Test data persistence
kubectl exec -it app-pod -- echo "Hello World" > /var/www/html/test.txt
kubectl delete pod app-pod
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: app-pod-2
spec:
  containers:
  - name: app
    image: nginx
    volumeMounts:
    - name: app-storage
      mountPath: /var/www/html
  volumes:
  - name: app-storage
    persistentVolumeClaim:
      claimName: app-pvc
EOF

# Verify data persistence
kubectl exec -it app-pod-2 -- cat /var/www/html/test.txt

# Expand PVC
kubectl patch pvc app-pvc -p '{"spec":{"resources":{"requests":{"storage":"10Gi"}}}}'
```

### Expected Outcomes
- PersistentVolumes created successfully
- PersistentVolumeClaims bound to PVs
- Pods can mount persistent storage
- Data persistence verified
