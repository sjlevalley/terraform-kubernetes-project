# Create Pods

## Task: CKAD - Pod Creation and Management

### Scenario
You need to create and manage pods for containerized applications.

### Tasks
1. **Create pods with different configurations**
   - Single container pod
   - Multi-container pod
   - Pod with resource limits

2. **Configure pod lifecycle**
   - Set up init containers
   - Configure post-start and pre-stop hooks
   - Handle pod termination

3. **Troubleshoot pod issues**
   - Debug pod startup problems
   - Check pod logs and events
   - Fix configuration issues

### Commands to Practice
```bash
# Create simple pod
kubectl run nginx-pod --image=nginx --restart=Never

# Create pod with YAML
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: web-pod
  labels:
    app: web
    tier: frontend
spec:
  containers:
  - name: nginx
    image: nginx:1.20
    ports:
    - containerPort: 80
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"
    livenessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 30
      periodSeconds: 10
    readinessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 5
      periodSeconds: 5
    lifecycle:
      postStart:
        exec:
          command: ["/bin/sh", "-c", "echo 'Pod started' > /tmp/startup.log"]
      preStop:
        exec:
          command: ["/bin/sh", "-c", "echo 'Pod stopping' > /tmp/shutdown.log"]
EOF

# Create pod with init container
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: init-pod
spec:
  initContainers:
  - name: init-setup
    image: busybox
    command: ['sh', '-c', 'echo "Initializing..." && sleep 10']
  containers:
  - name: app
    image: nginx
    ports:
    - containerPort: 80
EOF

# Create pod with environment variables
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: env-pod
spec:
  containers:
  - name: app
    image: busybox
    command: ['sh', '-c', 'echo "Environment: $ENV_NAME, Database: $DB_HOST" && sleep 3600']
    env:
    - name: ENV_NAME
      value: "production"
    - name: DB_HOST
      value: "db.example.com"
EOF

# Check pod status
kubectl get pods
kubectl describe pod web-pod

# Check pod logs
kubectl logs web-pod
kubectl logs init-pod -c init-setup

# Execute commands in pod
kubectl exec -it web-pod -- /bin/sh

# Check pod events
kubectl get events --sort-by=.metadata.creationTimestamp

# Port forward to pod
kubectl port-forward web-pod 8080:80

# Copy files to/from pod
kubectl cp web-pod:/etc/nginx/nginx.conf ./nginx.conf
kubectl cp ./config.txt web-pod:/tmp/config.txt

# Delete pod
kubectl delete pod web-pod

# Force delete pod
kubectl delete pod web-pod --force --grace-period=0
```

### Expected Outcomes
- Pods created with proper configuration
- Init containers working correctly
- Lifecycle hooks functioning
- Pod troubleshooting successful
