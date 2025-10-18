# Configure Kubernetes Gateway API

## Task: CKA/CKAD - Gateway API Implementation

### Scenario
You need to implement the new Kubernetes Gateway API for advanced traffic management and load balancing.

### Tasks
1. **Install Gateway API**
   - Install Gateway API CRDs
   - Deploy Gateway controller
   - Verify installation

2. **Configure Gateway resources**
   - Create GatewayClass
   - Create Gateway
   - Configure HTTPRoute

3. **Test Gateway functionality**
   - Deploy test applications
   - Configure routing rules
   - Verify traffic flow

### Commands to Practice
```bash
# Install Gateway API CRDs
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v0.8.1/standard-install.yaml

# Verify CRDs are installed
kubectl get crd | grep gateway

# Install NGINX Gateway Controller
kubectl apply -f https://raw.githubusercontent.com/nginxinc/nginx-kubernetes-gateway/v0.0.0-rc1/deploy/nginx-gateway.yaml

# Check Gateway controller pods
kubectl get pods -n nginx-gateway

# Create GatewayClass
kubectl apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1beta1
kind: GatewayClass
metadata:
  name: nginx-gateway-class
spec:
  controllerName: nginx.org/gateway-controller
EOF

# Create Gateway
kubectl apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1beta1
kind: Gateway
metadata:
  name: web-gateway
  namespace: default
spec:
  gatewayClassName: nginx-gateway-class
  listeners:
  - name: http
    port: 80
    protocol: HTTP
    allowedRoutes:
      namespaces:
        from: All
EOF

# Deploy test applications
kubectl create deployment web-app --image=nginx:1.20 --replicas=3
kubectl create deployment api-app --image=nginx:1.20 --replicas=2

# Create services
kubectl expose deployment web-app --port=80
kubectl expose deployment api-app --port=80

# Create HTTPRoute for web application
kubectl apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1beta1
kind: HTTPRoute
metadata:
  name: web-route
  namespace: default
spec:
  parentRefs:
  - name: web-gateway
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /
    backendRefs:
    - name: web-app
      port: 80
EOF

# Create HTTPRoute for API application
kubectl apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1beta1
kind: HTTPRoute
metadata:
  name: api-route
  namespace: default
spec:
  parentRefs:
  - name: web-gateway
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /api
    backendRefs:
    - name: api-app
      port: 80
EOF

# Check Gateway status
kubectl get gateway web-gateway
kubectl describe gateway web-gateway

# Check HTTPRoute status
kubectl get httproute
kubectl describe httproute web-route

# Get Gateway address
kubectl get gateway web-gateway -o jsonpath='{.status.addresses[0].value}'

# Test Gateway functionality
GATEWAY_IP=$(kubectl get gateway web-gateway -o jsonpath='{.status.addresses[0].value}')
curl -H "Host: web-gateway" http://$GATEWAY_IP/
curl -H "Host: web-gateway" http://$GATEWAY_IP/api

# Create HTTPRoute with header matching
kubectl apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1beta1
kind: HTTPRoute
metadata:
  name: header-route
  namespace: default
spec:
  parentRefs:
  - name: web-gateway
  rules:
  - matches:
    - headers:
      - name: X-Environment
        value: production
    backendRefs:
    - name: web-app
      port: 80
  - matches:
    - headers:
      - name: X-Environment
        value: staging
    backendRefs:
    - name: api-app
      port: 80
EOF

# Test header-based routing
curl -H "Host: web-gateway" -H "X-Environment: production" http://$GATEWAY_IP/
curl -H "Host: web-gateway" -H "X-Environment: staging" http://$GATEWAY_IP/

# Create HTTPRoute with method matching
kubectl apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1beta1
kind: HTTPRoute
metadata:
  name: method-route
  namespace: default
spec:
  parentRefs:
  - name: web-gateway
  rules:
  - matches:
    - method: GET
    backendRefs:
    - name: web-app
      port: 80
  - matches:
    - method: POST
    backendRefs:
    - name: api-app
      port: 80
EOF

# Test method-based routing
curl -X GET -H "Host: web-gateway" http://$GATEWAY_IP/
curl -X POST -H "Host: web-gateway" http://$GATEWAY_IP/

# Create HTTPRoute with query parameter matching
kubectl apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1beta1
kind: HTTPRoute
metadata:
  name: query-route
  namespace: default
spec:
  parentRefs:
  - name: web-gateway
  rules:
  - matches:
    - queryParams:
      - name: version
        value: v1
    backendRefs:
    - name: web-app
      port: 80
  - matches:
    - queryParams:
      - name: version
        value: v2
    backendRefs:
    - name: api-app
      port: 80
EOF

# Test query parameter routing
curl -H "Host: web-gateway" "http://$GATEWAY_IP/?version=v1"
curl -H "Host: web-gateway" "http://$GATEWAY_IP/?version=v2"

# Create HTTPRoute with traffic splitting
kubectl apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1beta1
kind: HTTPRoute
metadata:
  name: traffic-split-route
  namespace: default
spec:
  parentRefs:
  - name: web-gateway
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /split
    backendRefs:
    - name: web-app
      port: 80
      weight: 70
    - name: api-app
      port: 80
      weight: 30
EOF

# Test traffic splitting
for i in {1..10}; do
  curl -H "Host: web-gateway" http://$GATEWAY_IP/split
done

# Create HTTPRoute with redirect
kubectl apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1beta1
kind: HTTPRoute
metadata:
  name: redirect-route
  namespace: default
spec:
  parentRefs:
  - name: web-gateway
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /old
    filters:
    - type: RequestRedirect
      requestRedirect:
        statusCode: 301
        hostname: new.example.com
        path:
          type: ReplacePrefixMatch
          replacePrefixMatch: /new
EOF

# Test redirect
curl -I -H "Host: web-gateway" http://$GATEWAY_IP/old

# Create HTTPRoute with request header modification
kubectl apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1beta1
kind: HTTPRoute
metadata:
  name: header-mod-route
  namespace: default
spec:
  parentRefs:
  - name: web-gateway
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /modify
    filters:
    - type: RequestHeaderModifier
      requestHeaderModifier:
        add:
        - name: X-Added-Header
          value: "added-value"
        set:
        - name: X-Set-Header
          value: "set-value"
        remove:
        - "X-Remove-Header"
    backendRefs:
    - name: web-app
      port: 80
EOF

# Test header modification
curl -H "Host: web-gateway" -H "X-Remove-Header: remove-me" http://$GATEWAY_IP/modify

# Check Gateway API resources
kubectl get gatewayclass
kubectl get gateway
kubectl get httproute

# Check Gateway controller logs
kubectl logs -n nginx-gateway -l app=nginx-gateway

# Clean up Gateway API resources
kubectl delete httproute --all
kubectl delete gateway web-gateway
kubectl delete gatewayclass nginx-gateway-class
kubectl delete deployment web-app api-app
kubectl delete service web-app api-app
```

### Expected Outcomes
- Gateway API CRDs installed successfully
- Gateway controller running
- Gateway and HTTPRoute resources created
- Traffic routing working correctly
- Advanced routing features functional
