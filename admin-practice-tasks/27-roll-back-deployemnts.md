# Roll Back Deployments

## Task: CKA - Deployment Rollback Management

### Scenario
You need to roll back deployments when updates cause issues or fail to work as expected.

### Tasks
1. **Perform deployment rollbacks**
   - Roll back to previous version
   - Roll back to specific revision
   - Verify rollback success

2. **Manage rollout history**
   - View rollout history
   - Compare revisions
   - Clean up old revisions

3. **Troubleshoot rollback issues**
   - Handle rollback failures
   - Debug deployment issues
   - Fix configuration problems

### Commands to Practice
```bash
# Create initial deployment
kubectl create deployment web-app --image=nginx:1.20 --replicas=3

# Check deployment status
kubectl get deployments
kubectl rollout status deployment/web-app

# Update deployment to new version
kubectl set image deployment/web-app nginx=nginx:1.21

# Check rollout status
kubectl rollout status deployment/web-app

# Update deployment again
kubectl set image deployment/web-app nginx=nginx:1.22

# Check rollout history
kubectl rollout history deployment/web-app

# Get detailed history
kubectl rollout history deployment/web-app --revision=1
kubectl rollout history deployment/web-app --revision=2
kubectl rollout history deployment/web-app --revision=3

# Roll back to previous version
kubectl rollout undo deployment/web-app

# Check rollback status
kubectl rollout status deployment/web-app

# Verify rollback
kubectl get deployment web-app -o jsonpath='{.spec.template.spec.containers[0].image}'

# Roll back to specific revision
kubectl rollout undo deployment/web-app --to-revision=1

# Check rollback status
kubectl rollout status deployment/web-app

# Verify specific rollback
kubectl get deployment web-app -o jsonpath='{.spec.template.spec.containers[0].image}'

# Create deployment with change-cause annotation
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-with-annotations
spec:
  replicas: 2
  selector:
    matchLabels:
      app: app-with-annotations
  template:
    metadata:
      labels:
        app: app-with-annotations
    spec:
      containers:
      - name: nginx
        image: nginx:1.20
EOF

# Update with change-cause
kubectl patch deployment app-with-annotations -p '{"spec":{"template":{"spec":{"containers":[{"name":"nginx","image":"nginx:1.21"}]}}},"metadata":{"annotations":{"deployment.kubernetes.io/revision-history-limit":"10"}}}'

# Add change-cause annotation
kubectl annotate deployment app-with-annotations deployment.kubernetes.io/change-cause="Updated to nginx 1.21"

# Update again with change-cause
kubectl set image deployment/app-with-annotations nginx=nginx:1.22
kubectl annotate deployment app-with-annotations deployment.kubernetes.io/change-cause="Updated to nginx 1.22"

# Check history with change-cause
kubectl rollout history deployment/app-with-annotations

# Roll back with specific change-cause
kubectl rollout undo deployment/app-with-annotations --to-revision=2

# Check rollback status
kubectl rollout status deployment/app-with-annotations

# Create deployment with resource limits
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: resource-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: resource-app
  template:
    metadata:
      labels:
        app: resource-app
    spec:
      containers:
      - name: nginx
        image: nginx:1.20
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
EOF

# Update with problematic resource limits
kubectl patch deployment resource-app -p '{"spec":{"template":{"spec":{"containers":[{"name":"nginx","image":"nginx:1.21","resources":{"requests":{"memory":"1Gi","cpu":"1000m"},"limits":{"memory":"2Gi","cpu":"2000m"}}}]}}}}'

# Check if deployment is stuck
kubectl get pods -l app=resource-app
kubectl describe deployment resource-app

# Roll back due to resource issues
kubectl rollout undo deployment/resource-app

# Check rollback status
kubectl rollout status deployment/resource-app

# Verify rollback
kubectl get deployment resource-app -o jsonpath='{.spec.template.spec.containers[0].resources}'

# Create deployment with health checks
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: health-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: health-app
  template:
    metadata:
      labels:
        app: health-app
    spec:
      containers:
      - name: nginx
        image: nginx:1.20
        ports:
        - containerPort: 80
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

# Update with broken health check
kubectl patch deployment health-app -p '{"spec":{"template":{"spec":{"containers":[{"name":"nginx","image":"nginx:1.21","livenessProbe":{"httpGet":{"path":"/nonexistent","port":80},"initialDelaySeconds":30,"periodSeconds":10}}]}}}}'

# Check deployment status
kubectl get pods -l app=health-app
kubectl describe deployment health-app

# Roll back due to health check issues
kubectl rollout undo deployment/health-app

# Check rollback status
kubectl rollout status deployment/health-app

# Verify rollback
kubectl get deployment health-app -o jsonpath='{.spec.template.spec.containers[0].livenessProbe.httpGet.path}'

# Clean up old revisions
kubectl patch deployment web-app -p '{"spec":{"revisionHistoryLimit":3}}'

# Check final status
kubectl get deployments
kubectl rollout history deployment/web-app
```

### Expected Outcomes
- Deployments rolled back successfully
- Rollout history maintained
- Rollback status verified
- Old revisions cleaned up
- Deployment issues resolved
