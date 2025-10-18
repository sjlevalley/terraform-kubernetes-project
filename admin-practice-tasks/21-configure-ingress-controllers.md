# Configure Ingress Controllers

## Task: CKA/CKAD - Ingress Controller Setup

### Scenario
You need to set up and configure different Ingress controllers for your Kubernetes cluster.

### Tasks
1. **Install NGINX Ingress Controller**
   - Deploy NGINX Ingress Controller
   - Configure LoadBalancer service
   - Test basic functionality

2. **Install Traefik Ingress Controller**
   - Deploy Traefik using Helm
   - Configure dashboard access
   - Test advanced routing

3. **Install Istio Gateway**
   - Deploy Istio service mesh
   - Configure Gateway and VirtualService
   - Test service mesh features

### Commands to Practice
```bash
# Install NGINX Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml

# Wait for NGINX Ingress Controller to be ready
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s

# Check NGINX Ingress Controller
kubectl get pods -n ingress-nginx
kubectl get svc -n ingress-nginx

# Deploy test applications
kubectl create deployment web-app --image=nginx:1.20 --replicas=3
kubectl create deployment api-app --image=nginx:1.20 --replicas=2

# Create services
kubectl expose deployment web-app --port=80
kubectl expose deployment api-app --port=80

# Create basic Ingress
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: basic-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-app
            port:
              number: 80
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: api-app
            port:
              number: 80
EOF

# Check Ingress status
kubectl get ingress
kubectl describe ingress basic-ingress

# Get Ingress IP
kubectl get ingress basic-ingress -o jsonpath='{.status.loadBalancer.ingress[0].ip}'

# Test Ingress
INGRESS_IP=$(kubectl get ingress basic-ingress -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
curl -H "Host: example.com" http://$INGRESS_IP/
curl -H "Host: example.com" http://$INGRESS_IP/api

# Create Ingress with TLS
kubectl create secret tls tls-secret --cert=tls.crt --key=tls.key

kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: tls-ingress
spec:
  tls:
  - hosts:
    - example.com
    secretName: tls-secret
  rules:
  - host: example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-app
            port:
              number: 80
EOF

# Test TLS Ingress
curl -k -H "Host: example.com" https://$INGRESS_IP/

# Install Traefik using Helm
helm repo add traefik https://traefik.github.io/charts
helm repo update

# Install Traefik
helm install traefik traefik/traefik \
  --namespace traefik \
  --create-namespace \
  --set dashboard.enabled=true \
  --set dashboard.domain=traefik.example.com

# Check Traefik installation
kubectl get pods -n traefik
kubectl get svc -n traefik

# Create Traefik IngressRoute
kubectl apply -f - <<EOF
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: traefik-route
spec:
  entryPoints:
  - web
  routes:
  - match: Host(`traefik.example.com`)
    kind: Rule
    services:
    - name: api@internal
      kind: TraefikService
EOF

# Create Traefik IngressRoute for web app
kubectl apply -f - <<EOF
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: web-app-route
spec:
  entryPoints:
  - web
  routes:
  - match: Host(`web.example.com`)
    kind: Rule
    services:
    - name: web-app
      port: 80
  - match: Host(`api.example.com`)
    kind: Rule
    services:
    - name: api-app
      port: 80
EOF

# Check Traefik IngressRoute
kubectl get ingressroute
kubectl describe ingressroute web-app-route

# Install Istio
curl -L https://istio.io/downloadIstio | sh -
cd istio-*
export PATH=$PWD/bin:$PATH

# Install Istio
istioctl install --set values.defaultRevision=default

# Enable Istio sidecar injection
kubectl label namespace default istio-injection=enabled

# Deploy applications with Istio
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: istio-web-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: istio-web-app
  template:
    metadata:
      labels:
        app: istio-web-app
    spec:
      containers:
      - name: nginx
        image: nginx:1.20
        ports:
        - containerPort: 80
EOF

kubectl expose deployment istio-web-app --port=80

# Create Istio Gateway
kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: istio-gateway
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - istio.example.com
EOF

# Create Istio VirtualService
kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: istio-virtual-service
spec:
  hosts:
  - istio.example.com
  gateways:
  - istio-gateway
  http:
  - match:
    - uri:
        prefix: /
    route:
    - destination:
        host: istio-web-app
        port:
          number: 80
EOF

# Check Istio resources
kubectl get gateway
kubectl get virtualservice
kubectl get pods -l app=istio-web-app

# Get Istio Gateway IP
kubectl get svc istio-ingressgateway -n istio-system

# Test Istio Gateway
ISTIO_IP=$(kubectl get svc istio-ingressgateway -n istio-system -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
curl -H "Host: istio.example.com" http://$ISTIO_IP/

# Create Istio DestinationRule
kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: istio-destination-rule
spec:
  host: istio-web-app
  trafficPolicy:
    loadBalancer:
      simple: ROUND_ROBIN
EOF

# Create Istio ServiceEntry for external services
kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: ServiceEntry
metadata:
  name: external-service
spec:
  hosts:
  - external.example.com
  ports:
  - number: 80
    name: http
    protocol: HTTP
  location: MESH_EXTERNAL
  resolution: DNS
EOF

# Create Istio AuthorizationPolicy
kubectl apply -f - <<EOF
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: istio-auth-policy
spec:
  selector:
    matchLabels:
      app: istio-web-app
  rules:
  - from:
    - source:
        principals: ["cluster.local/ns/default/sa/default"]
    to:
    - operation:
        methods: ["GET"]
EOF

# Check Istio authorization
kubectl get authorizationpolicy

# Create Ingress with rate limiting (NGINX)
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: rate-limit-ingress
  annotations:
    nginx.ingress.kubernetes.io/rate-limit: "100"
    nginx.ingress.kubernetes.io/rate-limit-window: "1m"
spec:
  rules:
  - host: rate.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-app
            port:
              number: 80
EOF

# Test rate limiting
for i in {1..10}; do
  curl -H "Host: rate.example.com" http://$INGRESS_IP/
done

# Create Ingress with authentication (NGINX)
kubectl create secret generic basic-auth --from-literal=auth=$(htpasswd -nb admin password)

kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: auth-ingress
  annotations:
    nginx.ingress.kubernetes.io/auth-type: basic
    nginx.ingress.kubernetes.io/auth-secret: basic-auth
    nginx.ingress.kubernetes.io/auth-realm: 'Authentication Required'
spec:
  rules:
  - host: auth.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-app
            port:
              number: 80
EOF

# Test authentication
curl -H "Host: auth.example.com" http://$INGRESS_IP/
curl -u admin:password -H "Host: auth.example.com" http://$INGRESS_IP/

# Check all Ingress resources
kubectl get ingress
kubectl get ingressroute
kubectl get gateway
kubectl get virtualservice

# Check Ingress controller logs
kubectl logs -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx
kubectl logs -n traefik -l app.kubernetes.io/name=traefik
kubectl logs -n istio-system -l app=istiod

# Clean up resources
kubectl delete ingress --all
kubectl delete ingressroute --all
kubectl delete gateway --all
kubectl delete virtualservice --all
kubectl delete destinationrule --all
kubectl delete serviceentry --all
kubectl delete authorizationpolicy --all
kubectl delete deployment web-app api-app istio-web-app
kubectl delete service web-app api-app istio-web-app
```

### Expected Outcomes
- NGINX Ingress Controller installed and working
- Traefik Ingress Controller deployed with dashboard
- Istio Gateway and VirtualService configured
- Advanced routing features functional
- Authentication and rate limiting working
