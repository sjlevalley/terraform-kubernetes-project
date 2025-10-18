# Cluster Troubleshooting

## Task: Diagnose and Fix Cluster Issues

### Scenario
Your Kubernetes cluster is experiencing issues. You need to diagnose and resolve the problems.

### Tasks
1. **Check cluster health**
   - Verify all nodes are in Ready state
   - Check system pods are running
   - Identify any failed pods

2. **Troubleshoot node issues**
   - A worker node is showing as NotReady
   - Check node conditions and events
   - Restart kubelet service if needed

3. **Debug pod failures**
   - Pod is stuck in Pending state
   - Pod is in CrashLoopBackOff
   - Check logs and describe pod for issues

4. **Network connectivity issues**
   - Pods can't communicate with each other
   - DNS resolution problems
   - Service discovery issues

### Commands to Practice
```bash
# Check cluster status
kubectl get nodes
kubectl get pods --all-namespaces
kubectl get events --sort-by=.metadata.creationTimestamp

# Node troubleshooting
kubectl describe node <node-name>
kubectl get nodes -o wide
systemctl status kubelet

# Pod troubleshooting
kubectl describe pod <pod-name>
kubectl logs <pod-name>
kubectl logs <pod-name> --previous

# Network troubleshooting
kubectl get svc
kubectl get endpoints
kubectl exec -it <pod-name> -- nslookup kubernetes.default
```

### Expected Outcomes
- All nodes in Ready state
- All system pods running
- Application pods healthy
- Network connectivity working
