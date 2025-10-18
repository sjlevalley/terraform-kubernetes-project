# Create StatefulSets

## Task: CKAD - Stateful Application Management

### Scenario
You need to create and manage stateful applications using StatefulSets.

### Tasks
1. **Create StatefulSet**
   - Deploy stateful application with persistent storage
   - Configure ordered pod creation and deletion
   - Set up stable network identities

2. **Configure persistent storage**
   - Create headless service
   - Configure volume claim templates
   - Test data persistence across pod restarts

3. **Manage StatefulSet lifecycle**
   - Scale StatefulSet up and down
   - Update StatefulSet image
   - Handle pod failures

### Commands to Practice
```bash
# Create headless service
kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: web-headless
spec:
  clusterIP: None
  selector:
    app: web
  ports:
  - port: 80
    name: http
EOF

# Create StatefulSet
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web
spec:
  serviceName: web-headless
  replicas: 3
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: nginx
        image: nginx:1.20
        ports:
        - containerPort: 80
          name: http
        volumeMounts:
        - name: www
          mountPath: /usr/share/nginx/html
        - name: config
          mountPath: /etc/nginx/conf.d
  volumeClaimTemplates:
  - metadata:
      name: www
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 1Gi
EOF

# Create ConfigMap for nginx configuration
kubectl create configmap nginx-config --from-literal=default.conf="
server {
    listen 80;
    server_name localhost;
    location / {
        root /usr/share/nginx/html;
        index index.html;
    }
}
"

# Update StatefulSet to use ConfigMap
kubectl patch statefulset web -p '{
  "spec": {
    "template": {
      "spec": {
        "volumes": [
          {
            "name": "config",
            "configMap": {
              "name": "nginx-config"
            }
          }
        ]
      }
    }
  }
}'

# Check StatefulSet status
kubectl get statefulsets
kubectl describe statefulset web

# Check pods (should be created in order)
kubectl get pods -l app=web

# Check persistent volume claims
kubectl get pvc

# Scale StatefulSet
kubectl scale statefulset web --replicas=5

# Scale down StatefulSet
kubectl scale statefulset web --replicas=2

# Update StatefulSet image
kubectl patch statefulset web -p '{"spec":{"template":{"spec":{"containers":[{"name":"nginx","image":"nginx:1.21"}]}}}}'

# Check rollout status
kubectl rollout status statefulset web

# Rollback StatefulSet
kubectl rollout undo statefulset web

# Check rollout history
kubectl rollout history statefulset web

# Test pod identity
kubectl exec -it web-0 -- hostname
kubectl exec -it web-1 -- hostname

# Test persistent storage
kubectl exec -it web-0 -- sh -c 'echo "Hello from web-0" > /usr/share/nginx/html/index.html'
kubectl delete pod web-0
kubectl get pods -l app=web
kubectl exec -it web-0 -- cat /usr/share/nginx/html/index.html
```

### Expected Outcomes
- StatefulSet created with proper configuration
- Pods created in ordered sequence
- Persistent storage working correctly
- Scaling operations successful
