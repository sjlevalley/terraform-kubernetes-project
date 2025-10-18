# Create and Configure Deployments

## Task: CKAD - Deployment Management

### Scenario
You need to create and manage deployments for containerized applications.

### Tasks
1. **Create deployment**
   - Deploy a web application with multiple replicas
   - Configure resource limits and requests
   - Set up health checks

2. **Update deployment**
   - Perform rolling update to new image version
   - Scale deployment up and down
   - Configure deployment strategy

3. **Troubleshoot deployment issues**
   - Debug failed deployments
   - Check pod status and logs
   - Fix configuration issues

### Commands to Practice
```bash
# Create deployment
kubectl create deployment web-app --image=nginx:1.20 --replicas=3

# Create deployment with YAML
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
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
EOF

# Check deployment status
kubectl get deployments
kubectl describe deployment web-app

# Scale deployment
kubectl scale deployment web-app --replicas=5

# Update deployment image
kubectl set image deployment/web-app nginx=nginx:1.21

# Check rollout status
kubectl rollout status deployment/web-app

# Rollback deployment
kubectl rollout undo deployment/web-app

# Check rollout history
kubectl rollout history deployment/web-app
```

### Expected Outcomes
- Deployment created with proper configuration
- Rolling updates working correctly
- Scaling operations successful
- Health checks functioning
