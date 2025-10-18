# Configure RBAC (Role-Based Access Control)

## Task: Set Up Role-Based Access Control

### Scenario
You need to configure RBAC to control access to cluster resources for different users and service accounts.

### Tasks
1. **Create custom roles**
   - Create a role for developers (read-only access to pods, services)
   - Create a role for operators (full access to deployments, services)
   - Create a cluster role for monitoring (access to metrics, logs)

2. **Create service accounts and bindings**
   - Create service account for CI/CD pipeline
   - Bind service account to appropriate roles
   - Test access with kubectl auth can-i

3. **Configure user authentication**
   - Create user certificates
   - Set up kubeconfig for users
   - Test user access to resources

### Commands to Practice
```bash
# Create role for developers
kubectl create role developer --verb=get,list,watch --resource=pods,services,configmaps

# Create role binding
kubectl create rolebinding developer-binding --role=developer --user=developer1

# Create cluster role for monitoring
kubectl create clusterrole monitoring --verb=get,list,watch --resource=nodes,pods,services

# Create cluster role binding
kubectl create clusterrolebinding monitoring-binding --clusterrole=monitoring --user=monitor

# Create service account
kubectl create serviceaccount cicd-sa

# Bind service account to role
kubectl create rolebinding cicd-binding --role=developer --serviceaccount=default:cicd-sa

# Test access
kubectl auth can-i get pods --as=developer1
kubectl auth can-i create deployments --as=developer1
```

### Expected Outcomes
- Custom roles created with appropriate permissions
- Role bindings properly configured
- Service accounts have correct access
- Users can only access authorized resources
