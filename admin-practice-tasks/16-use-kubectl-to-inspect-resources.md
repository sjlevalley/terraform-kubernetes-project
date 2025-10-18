# Use kubectl to Inspect Resources

## Task: CKAD - Resource Inspection and Debugging

### Scenario
You need to inspect and debug Kubernetes resources using kubectl commands.

### Tasks
1. **Inspect pod resources**
   - Check pod status and conditions
   - View pod logs and events
   - Examine pod configuration

2. **Inspect service resources**
   - Check service endpoints
   - Verify service configuration
   - Test service connectivity

3. **Inspect deployment resources**
   - Check deployment status
   - View replica set information
   - Examine rollout history

### Commands to Practice
```bash
# Basic resource inspection
kubectl get pods
kubectl get pods -o wide
kubectl get pods --all-namespaces
kubectl get pods -l app=web
kubectl get pods --field-selector status.phase=Running

# Detailed resource information
kubectl describe pod <pod-name>
kubectl describe service <service-name>
kubectl describe deployment <deployment-name>
kubectl describe node <node-name>

# Resource logs
kubectl logs <pod-name>
kubectl logs <pod-name> --previous
kubectl logs <pod-name> -c <container-name>
kubectl logs -l app=web --tail=100
kubectl logs <pod-name> --since=1h

# Resource events
kubectl get events
kubectl get events --sort-by=.metadata.creationTimestamp
kubectl get events --field-selector involvedObject.name=<pod-name>
kubectl get events --field-selector type=Warning

# Resource configuration
kubectl get pod <pod-name> -o yaml
kubectl get pod <pod-name> -o json
kubectl get pod <pod-name> -o jsonpath='{.status.phase}'
kubectl get pod <pod-name> -o jsonpath='{.spec.containers[*].image}'

# Resource status
kubectl get pods -o custom-columns=NAME:.metadata.name,STATUS:.status.phase,READY:.status.containerStatuses[*].ready
kubectl get nodes -o custom-columns=NAME:.metadata.name,STATUS:.status.conditions[-1].type,ROLES:.metadata.labels.node-role\.kubernetes\.io/control-plane

# Resource debugging
kubectl exec -it <pod-name> -- /bin/sh
kubectl exec -it <pod-name> -c <container-name> -- /bin/sh
kubectl exec <pod-name> -- env
kubectl exec <pod-name> -- ps aux

# Port forwarding
kubectl port-forward <pod-name> 8080:80
kubectl port-forward service/<service-name> 8080:80
kubectl port-forward deployment/<deployment-name> 8080:80

# File operations
kubectl cp <pod-name>:/path/to/file ./local-file
kubectl cp ./local-file <pod-name>:/path/to/file
kubectl cp <pod-name>:/path/to/dir ./local-dir -c <container-name>

# Resource monitoring
kubectl top pods
kubectl top nodes
kubectl top pods --containers
kubectl top pods --sort-by=cpu
kubectl top pods --sort-by=memory

# Resource labels and annotations
kubectl get pods --show-labels
kubectl get pods -l app=web,version=v1
kubectl label pod <pod-name> environment=production
kubectl annotate pod <pod-name> description="Production web server"

# Resource scaling
kubectl scale deployment <deployment-name> --replicas=5
kubectl scale statefulset <statefulset-name> --replicas=3
kubectl autoscale deployment <deployment-name> --min=2 --max=10 --cpu-percent=50

# Resource rollout
kubectl rollout status deployment/<deployment-name>
kubectl rollout history deployment/<deployment-name>
kubectl rollout undo deployment/<deployment-name>
kubectl rollout undo deployment/<deployment-name> --to-revision=2

# Resource patches
kubectl patch pod <pod-name> -p '{"metadata":{"labels":{"new-label":"new-value"}}}'
kubectl patch deployment <deployment-name> -p '{"spec":{"template":{"spec":{"containers":[{"name":"nginx","image":"nginx:1.21"}]}}}}'

# Resource dry-run
kubectl run test-pod --image=nginx --dry-run=client -o yaml
kubectl create deployment test-deployment --image=nginx --dry-run=client -o yaml
kubectl apply -f deployment.yaml --dry-run=client

# Resource validation
kubectl apply -f deployment.yaml --validate=true
kubectl create -f deployment.yaml --validate=true
kubectl replace -f deployment.yaml --validate=true
```

### Expected Outcomes
- Resources inspected successfully
- Issues identified and diagnosed
- Resource status and configuration verified
- Debugging information gathered
