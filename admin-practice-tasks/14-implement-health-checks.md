# Implement Health Checks

## Task: CKAD - Application Health Monitoring

### Scenario
You need to implement health checks for your applications to ensure reliability and proper load balancing.

### Tasks
1. **Configure liveness probes**
   - HTTP health check endpoint
   - Command-based health check
   - TCP socket health check

2. **Configure readiness probes**
   - Application startup readiness
   - Database connection readiness
   - External service dependency checks

3. **Configure startup probes**
   - Slow-starting application support
   - Initial delay configuration
   - Startup timeout handling

### Commands to Practice
```bash
# Create deployment with liveness probe
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
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
          timeoutSeconds: 3
          failureThreshold: 3
        startupProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 10
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 30
EOF

# Create deployment with command-based health check
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-with-command-probe
spec:
  replicas: 2
  selector:
    matchLabels:
      app: app-with-command-probe
  template:
    metadata:
      labels:
        app: app-with-command-probe
    spec:
      containers:
      - name: app
        image: busybox
        command: ['sh', '-c', 'echo "App started" && sleep 3600']
        livenessProbe:
          exec:
            command:
            - sh
            - -c
            - 'ps aux | grep -v grep | grep sleep'
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          exec:
            command:
            - sh
            - -c
            - 'test -f /tmp/ready'
          initialDelaySeconds: 5
          periodSeconds: 5
EOF

# Create deployment with TCP socket health check
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-with-tcp-probe
spec:
  replicas: 2
  selector:
    matchLabels:
      app: app-with-tcp-probe
  template:
    metadata:
      labels:
        app: app-with-tcp-probe
    spec:
      containers:
      - name: redis
        image: redis:6
        ports:
        - containerPort: 6379
        livenessProbe:
          tcpSocket:
            port: 6379
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          exec:
            command:
            - redis-cli
            - ping
          initialDelaySeconds: 5
          periodSeconds: 5
EOF

# Create custom health check endpoint
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-with-health-endpoint
spec:
  replicas: 3
  selector:
    matchLabels:
      app: app-with-health-endpoint
  template:
    metadata:
      labels:
        app: app-with-health-endpoint
    spec:
      containers:
      - name: app
        image: nginx:1.20
        ports:
        - containerPort: 80
        livenessProbe:
          httpGet:
            path: /health
            port: 80
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
        volumeMounts:
        - name: nginx-config
          mountPath: /etc/nginx/conf.d
      volumes:
      - name: nginx-config
        configMap:
          name: nginx-health-config
EOF

# Create ConfigMap for health check endpoints
kubectl create configmap nginx-health-config --from-literal=health.conf="
server {
    listen 80;
    server_name localhost;
    
    location /health {
        access_log off;
        return 200 'healthy\n';
        add_header Content-Type text/plain;
    }
    
    location /ready {
        access_log off;
        return 200 'ready\n';
        add_header Content-Type text/plain;
    }
    
    location / {
        root /usr/share/nginx/html;
        index index.html;
    }
}
"

# Check deployment status
kubectl get deployments
kubectl describe deployment web-app

# Check pod status and health
kubectl get pods
kubectl describe pod <pod-name>

# Check probe status
kubectl get pods -o wide
kubectl logs <pod-name>

# Test health check endpoints
kubectl port-forward <pod-name> 8080:80
curl http://localhost:8080/health
curl http://localhost:8080/ready

# Simulate health check failure
kubectl exec -it <pod-name> -- rm /usr/share/nginx/html/index.html
kubectl get pods -w

# Check events for probe failures
kubectl get events --sort-by=.metadata.creationTimestamp
```

### Expected Outcomes
- Health checks configured correctly
- Pods restart on liveness probe failures
- Pods removed from service on readiness probe failures
- Startup probes handle slow-starting applications
