# Debug Application Failures

## Task: CKAD - Application Troubleshooting

### Scenario
You need to debug and fix application failures in your Kubernetes cluster.

### Tasks
1. **Debug pod failures**
   - Pod stuck in Pending state
   - Pod in CrashLoopBackOff
   - Pod not responding to health checks

2. **Debug service connectivity issues**
   - Service not accessible
   - DNS resolution problems
   - Network policy blocking traffic

3. **Debug deployment issues**
   - Deployment not updating
   - Rolling update failures
   - Resource constraint issues

### Commands to Practice
```bash
# Check pod status
kubectl get pods
kubectl describe pod <pod-name>

# Check pod logs
kubectl logs <pod-name>
kubectl logs <pod-name> --previous
kubectl logs <pod-name> -c <container-name>

# Check events
kubectl get events --sort-by=.metadata.creationTimestamp
kubectl get events --field-selector involvedObject.name=<pod-name>

# Debug pod in Pending state
kubectl describe pod <pod-name>
kubectl get nodes
kubectl describe node <node-name>

# Debug CrashLoopBackOff
kubectl logs <pod-name> --previous
kubectl describe pod <pod-name>
kubectl exec -it <pod-name> -- /bin/sh

# Check resource usage
kubectl top pods
kubectl top nodes
kubectl describe pod <pod-name> | grep -A 5 "Requests\|Limits"

# Debug service issues
kubectl get svc
kubectl describe svc <service-name>
kubectl get endpoints <service-name>

# Test service connectivity
kubectl run test-pod --image=busybox --rm -it --restart=Never -- wget -O- <service-name>
kubectl run test-pod --image=busybox --rm -it --restart=Never -- nslookup <service-name>

# Debug DNS issues
kubectl run test-pod --image=busybox --rm -it --restart=Never -- nslookup kubernetes.default.svc.cluster.local

# Check network policies
kubectl get networkpolicies
kubectl describe networkpolicy <policy-name>

# Debug deployment issues
kubectl get deployments
kubectl describe deployment <deployment-name>
kubectl rollout status deployment/<deployment-name>
kubectl rollout history deployment/<deployment-name>

# Check replica set
kubectl get replicasets
kubectl describe replicaset <rs-name>

# Debug ingress issues
kubectl get ingress
kubectl describe ingress <ingress-name>
kubectl get ingressclass

# Check persistent volume issues
kubectl get pv
kubectl get pvc
kubectl describe pv <pv-name>
kubectl describe pvc <pvc-name>

# Debug configmap and secret issues
kubectl get configmaps
kubectl get secrets
kubectl describe configmap <cm-name>
kubectl describe secret <secret-name>

# Check pod security context
kubectl describe pod <pod-name> | grep -A 10 "Security Context"

# Debug resource quotas
kubectl get resourcequotas
kubectl describe resourcequota <quota-name>

# Check limit ranges
kubectl get limitranges
kubectl describe limitrange <limit-name>
```

### Expected Outcomes
- Pod failures diagnosed and resolved
- Service connectivity issues fixed
- Deployment problems resolved
- Application running successfully
