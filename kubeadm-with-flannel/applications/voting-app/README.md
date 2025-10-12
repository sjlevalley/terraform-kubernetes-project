# Voting App - Kubernetes Example

This is the Docker Voting App example deployed on Kubernetes. It demonstrates a complete microservices architecture with frontend, backend, and database components.

## Architecture

- **Vote Frontend**: Python Flask web app for voting (Cats vs Dogs)
- **Result Frontend**: Node.js web app showing voting results
- **Worker**: Node.js background service processing votes
- **Redis**: In-memory database for vote queue
- **PostgreSQL**: Persistent database for storing results

## Deployment

### Prerequisites
- Kubernetes cluster is running
- kubectl is configured to access the cluster

### Deploy the Application

```bash
# Deploy all components
kubectl apply -f .

# Check deployment status
kubectl get pods
kubectl get services
```

### Access the Application

The application will be accessible via NodePort:

- **Vote App**: `http://100.27.206.7:30001`
- **Result App**: `http://100.27.206.7:30002`

**Note**: The master node public IP is `100.27.206.7`. If you're accessing from within the VPC, you can also use the private IP `172.31.19.223`.

### Testing the Application

1. **Vote**: Go to the vote app and click on "Cats" or "Dogs"
2. **View Results**: Go to the result app to see the voting results
3. **Check Logs**: Use `kubectl logs -f deployment/worker` to see vote processing

## Useful Commands

```bash
# Check all pods
kubectl get pods

# Check all services
kubectl get services

# Check logs
kubectl logs -f deployment/vote
kubectl logs -f deployment/result
kubectl logs -f deployment/worker

# Scale the vote app
kubectl scale deployment vote --replicas=3

# Delete the application
kubectl delete -f .
```

## Troubleshooting

### If pods are not starting:
```bash
# Check pod status
kubectl describe pod <pod-name>

# Check events
kubectl get events --sort-by=.metadata.creationTimestamp
```

### If services are not accessible:
```bash
# Check service endpoints
kubectl get endpoints

# Check if NodePort is open in security groups
# Ensure ports 30001 and 30002 are open
```

## Components

| Component | Image | Port | Service Type |
|-----------|-------|------|--------------|
| Vote | dockersamples/examplevotingapp_vote:before | 80 | NodePort (30001) |
| Result | dockersamples/examplevotingapp_result:before | 80 | NodePort (30002) |
| Worker | dockersamples/examplevotingapp_worker | - | None |
| Redis | redis:alpine | 6379 | ClusterIP |
| PostgreSQL | postgres:15-alpine | 5432 | ClusterIP |
