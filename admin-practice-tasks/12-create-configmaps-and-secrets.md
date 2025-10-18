# Create ConfigMaps and Secrets

## Task: CKAD - Configuration Management

### Scenario
You need to manage application configuration and sensitive data using ConfigMaps and Secrets.

### Tasks
1. **Create ConfigMaps**
   - Create ConfigMap from files
   - Create ConfigMap from literals
   - Mount ConfigMap in pods

2. **Create Secrets**
   - Create secret for database credentials
   - Create secret for TLS certificates
   - Mount secrets in pods

3. **Use ConfigMaps and Secrets in deployments**
   - Configure environment variables
   - Mount as volumes
   - Update configurations

### Commands to Practice
```bash
# Create ConfigMap from file
kubectl create configmap app-config --from-file=config.properties

# Create ConfigMap from literals
kubectl create configmap app-config --from-literal=database_host=db.example.com --from-literal=database_port=5432

# Create ConfigMap with YAML
kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  database_host: "db.example.com"
  database_port: "5432"
  app.properties: |
    server.port=8080
    logging.level=INFO
EOF

# Create Secret from file
kubectl create secret generic db-secret --from-file=username.txt --from-file=password.txt

# Create Secret from literals
kubectl create secret generic db-secret --from-literal=username=admin --from-literal=password=secret123

# Create Secret with YAML
kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: db-secret
type: Opaque
data:
  username: YWRtaW4=  # base64 encoded
  password: c2VjcmV0MTIz  # base64 encoded
EOF

# Use ConfigMap and Secret in deployment
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
spec:
  replicas: 1
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
        image: nginx
        env:
        - name: DB_HOST
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: database_host
        - name: DB_USERNAME
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: username
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: password
        volumeMounts:
        - name: config-volume
          mountPath: /etc/config
        - name: secret-volume
          mountPath: /etc/secrets
          readOnly: true
      volumes:
      - name: config-volume
        configMap:
          name: app-config
      - name: secret-volume
        secret:
          secretName: db-secret
EOF

# Check ConfigMap and Secret
kubectl get configmaps
kubectl get secrets
kubectl describe configmap app-config
kubectl describe secret db-secret
```

### Expected Outcomes
- ConfigMaps created and mounted correctly
- Secrets created and accessible
- Environment variables configured
- Volume mounts working
