# Configure Service Accounts

## Task: Set Up Service Accounts and Authentication

### Scenario
You need to configure service accounts for applications and set up proper authentication mechanisms.

### Tasks
1. **Create service accounts**
   - Create service account for application pods
   - Create service account for external services
   - Configure image pull secrets

2. **Set up authentication**
   - Create service account tokens
   - Configure kubeconfig for service accounts
   - Test authentication from pods

3. **Configure RBAC for service accounts**
   - Bind service accounts to appropriate roles
   - Test access to cluster resources
   - Verify least privilege principle

### Commands to Practice
```bash
# Create service account
kubectl create serviceaccount app-sa

# Create image pull secret
kubectl create secret docker-registry regcred \
  --docker-server=your-registry.com \
  --docker-username=your-username \
  --docker-password=your-password \
  --docker-email=your-email

# Link secret to service account
kubectl patch serviceaccount app-sa -p '{"imagePullSecrets": [{"name": "regcred"}]}'

# Create role and bind to service account
kubectl create role app-role --verb=get,list,watch --resource=pods,services
kubectl create rolebinding app-binding --role=app-role --serviceaccount=default:app-sa

# Deploy pod with service account
kubectl run test-pod --image=nginx --serviceaccount=app-sa --restart=Never

# Test access from pod
kubectl exec -it test-pod -- curl -k https://kubernetes.default.svc/api/v1/namespaces/default/pods
```

### Expected Outcomes
- Service accounts created and configured
- Image pull secrets properly linked
- RBAC bindings working correctly
- Pods can authenticate and access authorized resources
