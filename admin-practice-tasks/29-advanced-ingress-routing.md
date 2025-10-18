# Advanced Ingress Routing

## Task: CKAD - Advanced Ingress Configuration

### Scenario
You need to implement advanced Ingress routing patterns for complex application architectures.

### Tasks
1. **Implement canary deployments**
   - Set up traffic splitting
   - Configure gradual rollouts
   - Monitor canary performance

2. **Configure blue-green deployments**
   - Set up traffic switching
   - Implement instant rollbacks
   - Test deployment strategies

3. **Implement A/B testing**
   - Configure header-based routing
   - Set up user segmentation
   - Analyze traffic patterns

### Commands to Practice
```bash
# Deploy canary application versions
kubectl create deployment web-app-stable --image=nginx:1.20 --replicas=3
kubectl create deployment web-app-canary --image=nginx:1.21 --replicas=1

# Create services
kubectl expose deployment web-app-stable --port=80
kubectl expose deployment web-app-canary --port=80

# Create canary Ingress with traffic splitting
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: canary-ingress
  annotations:
    nginx.ingress.kubernetes.io/canary: "true"
    nginx.ingress.kubernetes.io/canary-weight: "10"
spec:
  rules:
  - host: canary.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-app-stable
            port:
              number: 80
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: canary-ingress-canary
  annotations:
    nginx.ingress.kubernetes.io/canary: "true"
    nginx.ingress.kubernetes.io/canary-weight: "10"
spec:
  rules:
  - host: canary.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-app-canary
            port:
              number: 80
EOF

# Test canary deployment
INGRESS_IP=$(kubectl get ingress canary-ingress -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
for i in {1..20}; do
  curl -H "Host: canary.example.com" http://$INGRESS_IP/
done

# Increase canary traffic to 50%
kubectl patch ingress canary-ingress -p '{"metadata":{"annotations":{"nginx.ingress.kubernetes.io/canary-weight":"50"}}}'
kubectl patch ingress canary-ingress-canary -p '{"metadata":{"annotations":{"nginx.ingress.kubernetes.io/canary-weight":"50"}}}'

# Test increased canary traffic
for i in {1..20}; do
  curl -H "Host: canary.example.com" http://$INGRESS_IP/
done

# Deploy blue-green applications
kubectl create deployment web-app-blue --image=nginx:1.20 --replicas=3
kubectl create deployment web-app-green --image=nginx:1.21 --replicas=3

# Create services
kubectl expose deployment web-app-blue --port=80
kubectl expose deployment web-app-green --port=80

# Create blue-green Ingress
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: blue-green-ingress
spec:
  rules:
  - host: bluegreen.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-app-blue
            port:
              number: 80
EOF

# Test blue deployment
curl -H "Host: bluegreen.example.com" http://$INGRESS_IP/

# Switch to green deployment
kubectl patch ingress blue-green-ingress -p '{"spec":{"rules":[{"host":"bluegreen.example.com","http":{"paths":[{"path":"/","pathType":"Prefix","backend":{"service":{"name":"web-app-green","port":{"number":80}}}}]}}]}}'

# Test green deployment
curl -H "Host: bluegreen.example.com" http://$INGRESS_IP/

# Switch back to blue deployment
kubectl patch ingress blue-green-ingress -p '{"spec":{"rules":[{"host":"bluegreen.example.com","http":{"paths":[{"path":"/","pathType":"Prefix","backend":{"service":{"name":"web-app-blue","port":{"number":80}}}}]}}]}}'

# Deploy A/B testing applications
kubectl create deployment web-app-version-a --image=nginx:1.20 --replicas=2
kubectl create deployment web-app-version-b --image=nginx:1.21 --replicas=2

# Create services
kubectl expose deployment web-app-version-a --port=80
kubectl expose deployment web-app-version-b --port=80

# Create A/B testing Ingress with header-based routing
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ab-test-ingress
  annotations:
    nginx.ingress.kubernetes.io/server-snippet: |
      if ($http_x_test_group = "A") {
        return 301 http://$host/version-a$request_uri;
      }
      if ($http_x_test_group = "B") {
        return 301 http://$host/version-b$request_uri;
      }
spec:
  rules:
  - host: abtest.example.com
    http:
      paths:
      - path: /version-a
        pathType: Prefix
        backend:
          service:
            name: web-app-version-a
            port:
              number: 80
      - path: /version-b
        pathType: Prefix
        backend:
          service:
            name: web-app-version-b
            port:
              number: 80
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-app-version-a
            port:
              number: 80
EOF

# Test A/B routing
curl -H "Host: abtest.example.com" -H "X-Test-Group: A" http://$INGRESS_IP/
curl -H "Host: abtest.example.com" -H "X-Test-Group: B" http://$INGRESS_IP/
curl -H "Host: abtest.example.com" http://$INGRESS_IP/

# Create A/B testing with cookie-based routing
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ab-test-cookie-ingress
  annotations:
    nginx.ingress.kubernetes.io/server-snippet: |
      if ($cookie_test_group = "A") {
        return 301 http://$host/version-a$request_uri;
      }
      if ($cookie_test_group = "B") {
        return 301 http://$host/version-b$request_uri;
      }
spec:
  rules:
  - host: abcookie.example.com
    http:
      paths:
      - path: /version-a
        pathType: Prefix
        backend:
          service:
            name: web-app-version-a
            port:
              number: 80
      - path: /version-b
        pathType: Prefix
        backend:
          service:
            name: web-app-version-b
            port:
              number: 80
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-app-version-a
            port:
              number: 80
EOF

# Test cookie-based A/B routing
curl -H "Host: abcookie.example.com" -H "Cookie: test_group=A" http://$INGRESS_IP/
curl -H "Host: abcookie.example.com" -H "Cookie: test_group=B" http://$INGRESS_IP/

# Create geographic routing
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: geo-routing-ingress
  annotations:
    nginx.ingress.kubernetes.io/server-snippet: |
      if ($geoip_country_code = "US") {
        return 301 http://$host/us$request_uri;
      }
      if ($geoip_country_code = "EU") {
        return 301 http://$host/eu$request_uri;
      }
spec:
  rules:
  - host: geo.example.com
    http:
      paths:
      - path: /us
        pathType: Prefix
        backend:
          service:
            name: web-app-version-a
            port:
              number: 80
      - path: /eu
        pathType: Prefix
        backend:
          service:
            name: web-app-version-b
            port:
              number: 80
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-app-version-a
            port:
              number: 80
EOF

# Create time-based routing
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: time-based-ingress
  annotations:
    nginx.ingress.kubernetes.io/server-snippet: |
      if ($time_iso8601 ~ "^[0-9]{4}-[0-9]{2}-[0-9]{2}T([0-9]{2}):") {
        set $hour $1;
      }
      if ($hour ~ "^(0[0-9]|1[0-1])$") {
        return 301 http://$host/maintenance$request_uri;
      }
spec:
  rules:
  - host: time.example.com
    http:
      paths:
      - path: /maintenance
        pathType: Prefix
        backend:
          service:
            name: web-app-version-a
            port:
              number: 80
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-app-version-b
            port:
              number: 80
EOF

# Create rate limiting per user
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: rate-limit-user-ingress
  annotations:
    nginx.ingress.kubernetes.io/rate-limit: "10"
    nginx.ingress.kubernetes.io/rate-limit-window: "1m"
    nginx.ingress.kubernetes.io/rate-limit-key: "$binary_remote_addr"
spec:
  rules:
  - host: ratelimit.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-app-version-a
            port:
              number: 80
EOF

# Test rate limiting
for i in {1..15}; do
  curl -H "Host: ratelimit.example.com" http://$INGRESS_IP/
done

# Create circuit breaker pattern
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: circuit-breaker-ingress
  annotations:
    nginx.ingress.kubernetes.io/upstream-hash-by: "$binary_remote_addr"
    nginx.ingress.kubernetes.io/upstream-keepalive-connections: "32"
    nginx.ingress.kubernetes.io/upstream-keepalive-requests: "100"
    nginx.ingress.kubernetes.io/upstream-keepalive-timeout: "60s"
spec:
  rules:
  - host: circuit.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-app-version-a
            port:
              number: 80
EOF

# Create health check endpoint
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: health-check-ingress
  annotations:
    nginx.ingress.kubernetes.io/health-check-path: "/health"
    nginx.ingress.kubernetes.io/health-check-interval: "30s"
    nginx.ingress.kubernetes.io/health-check-timeout: "5s"
    nginx.ingress.kubernetes.io/health-check-retries: "3"
spec:
  rules:
  - host: health.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-app-version-a
            port:
              number: 80
EOF

# Check all Ingress resources
kubectl get ingress
kubectl describe ingress canary-ingress
kubectl describe ingress blue-green-ingress
kubectl describe ingress ab-test-ingress

# Monitor Ingress metrics
kubectl get --raw /metrics | grep nginx_ingress

# Check Ingress controller logs
kubectl logs -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx | grep -E "(canary|blue-green|ab-test)"

# Clean up resources
kubectl delete ingress --all
kubectl delete deployment web-app-stable web-app-canary web-app-blue web-app-green web-app-version-a web-app-version-b
kubectl delete service web-app-stable web-app-canary web-app-blue web-app-green web-app-version-a web-app-version-b
```

### Expected Outcomes
- Canary deployments working with traffic splitting
- Blue-green deployments with instant switching
- A/B testing with header and cookie-based routing
- Geographic and time-based routing functional
- Rate limiting and circuit breaker patterns implemented
