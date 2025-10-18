# Network Policies

## Task: CKA - Network Security Configuration

### Scenario
You need to implement network policies to secure communication between pods and control network traffic.

### Tasks
1. **Create network policies**
   - Allow traffic between specific pods
   - Deny all ingress traffic by default
   - Configure egress rules

2. **Test network policy enforcement**
   - Verify allowed traffic works
   - Confirm blocked traffic is denied
   - Test policy updates

3. **Troubleshoot network policies**
   - Debug connectivity issues
   - Check policy enforcement
   - Verify policy configuration

### Commands to Practice
```bash
# Create namespace for testing
kubectl create namespace network-test

# Deploy test applications
kubectl run web-server --image=nginx --namespace=network-test
kubectl run client --image=busybox --namespace=network-test -- sleep 3600

# Create network policy to deny all ingress
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all-ingress
  namespace: network-test
spec:
  podSelector: {}
  policyTypes:
  - Ingress
EOF

# Test connectivity (should fail)
kubectl exec -it client --namespace=network-test -- wget -O- web-server

# Create network policy to allow specific traffic
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-web-traffic
  namespace: network-test
spec:
  podSelector:
    matchLabels:
      run: web-server
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          run: client
    ports:
    - protocol: TCP
      port: 80
EOF

# Test connectivity (should work)
kubectl exec -it client --namespace=network-test -- wget -O- web-server

# Create network policy for egress
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-dns-egress
  namespace: network-test
spec:
  podSelector: {}
  policyTypes:
  - Egress
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          name: kube-system
    ports:
    - protocol: UDP
      port: 53
  - to:
    - namespaceSelector:
        matchLabels:
          name: kube-system
    ports:
    - protocol: TCP
      port: 53
EOF

# Test DNS resolution
kubectl exec -it client --namespace=network-test -- nslookup kubernetes.default.svc.cluster.local

# Create network policy with IP blocks
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-specific-ips
  namespace: network-test
spec:
  podSelector:
    matchLabels:
      run: web-server
  policyTypes:
  - Ingress
  ingress:
  - from:
    - ipBlock:
        cidr: 10.0.0.0/8
        except:
        - 10.0.1.0/24
    ports:
    - protocol: TCP
      port: 80
EOF

# Check network policies
kubectl get networkpolicies --namespace=network-test
kubectl describe networkpolicy allow-web-traffic --namespace=network-test

# Test policy enforcement
kubectl run test-pod --image=busybox --namespace=network-test -- sleep 3600
kubectl exec -it test-pod --namespace=network-test -- wget -O- web-server

# Delete network policies
kubectl delete networkpolicy --all --namespace=network-test

# Clean up
kubectl delete namespace network-test
```

### Expected Outcomes
- Network policies created and enforced
- Traffic allowed/denied as configured
- DNS resolution working with egress policies
- Policy troubleshooting successful
