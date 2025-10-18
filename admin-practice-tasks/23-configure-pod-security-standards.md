# Configure Pod Security Standards

## Task: Implement Pod Security Standards

### Scenario
You need to configure Pod Security Standards to enforce security policies across your cluster.

### Tasks
1. **Create Pod Security Policy**
   - Define a restrictive policy for production workloads
   - Allow privileged containers only in specific namespaces
   - Enforce non-root user execution

2. **Configure namespace-level security**
   - Apply `restricted` policy to production namespaces
   - Apply `baseline` policy to development namespaces
   - Apply `privileged` policy to system namespaces

3. **Test security enforcement**
   - Deploy a pod that violates security policy
   - Verify the pod is rejected
   - Fix the pod to comply with policy

### Commands to Practice
```bash
# Create Pod Security Policy
kubectl apply -f - <<EOF
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: restricted-psp
spec:
  privileged: false
  allowPrivilegeEscalation: false
  requiredDropCapabilities:
    - ALL
  volumes:
    - 'configMap'
    - 'emptyDir'
    - 'projected'
    - 'secret'
    - 'downwardAPI'
    - 'persistentVolumeClaim'
  runAsUser:
    rule: 'MustRunAsNonRoot'
  seLinux:
    rule: 'RunAsAny'
  fsGroup:
    rule: 'RunAsAny'
EOF

# Configure namespace security
kubectl label namespace production pod-security.kubernetes.io/enforce=restricted
kubectl label namespace development pod-security.kubernetes.io/enforce=baseline
kubectl label namespace kube-system pod-security.kubernetes.io/enforce=privileged

# Test security policy
kubectl run test-pod --image=nginx --restart=Never --dry-run=client -o yaml
```

### Expected Outcomes
- Pod Security Policy created and enforced
- Namespaces properly labeled with security standards
- Violating pods are rejected
- Compliant pods deploy successfully
