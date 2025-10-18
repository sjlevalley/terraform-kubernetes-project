# Create and Configure Services

## Task: CKAD - Service Configuration

### Scenario
You need to create and configure services to expose your applications within and outside the cluster.

### Tasks
1. **Create different service types**
   - ClusterIP service for internal communication
   - NodePort service for external access
   - LoadBalancer service for cloud environments

2. **Configure service discovery**
   - Set up service endpoints
   - Configure service selectors
   - Test service connectivity

3. **Troubleshoot service issues**
   - Debug service connectivity problems
   - Check endpoint configuration
   - Verify service DNS resolution

### Commands to Practice
```bash
# Create ClusterIP service
kubectl create service clusterip web-service --tcp=80:80

# Create NodePort service
kubectl create service nodeport web-service --tcp=80:80 --node-port=30080

# Create LoadBalancer service
kubectl create service loadbalancer web-service --tcp=80:80

# Create service with YAML
kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: web-service
spec:
  type: NodePort
  selector:
    app: web-app
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
    protocol: TCP
EOF

# Check service status
kubectl get services
kubectl describe service web-service

# Check service endpoints
kubectl get endpoints web-service

# Test service connectivity
kubectl run test-pod --image=busybox --rm -it --restart=Never -- wget -O- web-service

# Test DNS resolution
kubectl run test-pod --image=busybox --rm -it --restart=Never -- nslookup web-service

# Port forward to service
kubectl port-forward service/web-service 8080:80

# Check service logs
kubectl logs -l app=web-app
```

### Expected Outcomes
- Services created with correct configuration
- Service discovery working
- External access functional
- DNS resolution working
