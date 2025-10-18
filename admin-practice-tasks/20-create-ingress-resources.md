# Create Ingress Resources

## Task: CKAD - Ingress Configuration

### Scenario
You need to configure Ingress resources to expose HTTP and HTTPS services with path-based routing.

### Tasks
1. **Create Ingress controller**
   - Install NGINX Ingress Controller
   - Configure Ingress controller
   - Verify controller is running

2. **Create Ingress resources**
   - Configure path-based routing
   - Set up TLS termination
   - Configure multiple hosts

3. **Test Ingress functionality**
   - Verify routing works correctly
   - Test TLS termination
   - Check ingress status

### Commands to Practice
```bash
# Install NGINX Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml

# Wait for ingress controller to be ready
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s

# Create services for ingress
kubectl create deployment web-app --image=nginx
kubectl expose deployment web-app --port=80

kubectl create deployment api-app --image=nginx
kubectl expose deployment api-app --port=80

# Create Ingress resource
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: example-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-app
            port:
              number: 80
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: api-app
            port:
              number: 80
EOF

# Create TLS Ingress
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: tls-ingress
spec:
  tls:
  - hosts:
    - example.com
    secretName: tls-secret
  rules:
  - host: example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-app
            port:
              number: 80
EOF

# Create TLS secret
kubectl create secret tls tls-secret --cert=tls.crt --key=tls.key

# Check ingress status
kubectl get ingress
kubectl describe ingress example-ingress

# Test ingress (replace with actual ingress IP)
curl -H "Host: example.com" http://<ingress-ip>/
curl -H "Host: example.com" http://<ingress-ip>/api

# Check ingress controller logs
kubectl logs -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx
```

### Expected Outcomes
- Ingress controller installed and running
- Ingress resources created successfully
- Path-based routing working
- TLS termination configured
