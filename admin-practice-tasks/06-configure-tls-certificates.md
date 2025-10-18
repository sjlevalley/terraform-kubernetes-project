# Configure TLS Certificates

## Task: Set Up TLS Certificates and PKI

### Scenario
You need to configure TLS certificates for secure communication within the cluster and with external services.

### Tasks
1. **Generate CA and certificates**
   - Create a Certificate Authority (CA)
   - Generate server certificates for API server
   - Generate client certificates for users

2. **Configure cluster certificates**
   - Update kubeconfig with client certificates
   - Verify certificate validity
   - Test secure connections

3. **Set up certificate rotation**
   - Configure automatic certificate renewal
   - Test certificate expiration handling
   - Update certificates manually if needed

### Commands to Practice
```bash
# Generate CA private key
openssl genrsa -out ca.key 2048

# Generate CA certificate
openssl req -new -x509 -key ca.key -out ca.crt -days 365 -subj "/CN=Kubernetes-CA"

# Generate server private key
openssl genrsa -out server.key 2048

# Generate server certificate signing request
openssl req -new -key server.key -out server.csr -subj "/CN=kube-apiserver"

# Sign server certificate with CA
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 365

# Generate client private key
openssl genrsa -out client.key 2048

# Generate client certificate signing request
openssl req -new -key client.key -out client.csr -subj "/CN=admin/O=system:masters"

# Sign client certificate with CA
openssl x509 -req -in client.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out client.crt -days 365

# Update kubeconfig with certificates
kubectl config set-credentials admin --client-certificate=client.crt --client-key=client.key --embed-certs=true
kubectl config set-cluster kubernetes --certificate-authority=ca.crt --embed-certs=true

# Verify certificate
openssl x509 -in server.crt -text -noout
```

### Expected Outcomes
- CA and certificates generated successfully
- Kubeconfig updated with proper certificates
- Secure connections established
- Certificate validity verified
