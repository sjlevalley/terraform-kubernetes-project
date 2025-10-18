# Setup Logging and Monitoring

## Task: CKA - Observability Configuration

### Scenario
You need to set up comprehensive logging and monitoring for your Kubernetes cluster.

### Tasks
1. **Configure cluster logging**
   - Set up centralized logging
   - Configure log aggregation
   - Implement log retention policies

2. **Set up monitoring stack**
   - Install Prometheus and Grafana
   - Configure metrics collection
   - Set up alerting rules

3. **Implement observability best practices**
   - Configure health checks
   - Set up distributed tracing
   - Monitor resource usage

### Commands to Practice
```bash
# Install Helm for package management
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Add Prometheus Helm repository
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install Prometheus
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --set grafana.adminPassword=admin123

# Check Prometheus installation
kubectl get pods -n monitoring
kubectl get svc -n monitoring

# Access Grafana (port forward)
kubectl port-forward svc/prometheus-grafana 3000:80 -n monitoring

# Install Fluentd for logging
kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: fluentd-config
  namespace: kube-system
data:
  fluent.conf: |
    <source>
      @type tail
      path /var/log/containers/*.log
      pos_file /var/log/fluentd-containers.log.pos
      tag kubernetes.*
      format json
      time_key time
      time_format %Y-%m-%dT%H:%M:%S.%NZ
    </source>
    
    <filter kubernetes.**>
      @type kubernetes_metadata
    </filter>
    
    <match kubernetes.**>
      @type stdout
    </match>
EOF

# Create Fluentd DaemonSet
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluentd
  namespace: kube-system
spec:
  selector:
    matchLabels:
      name: fluentd
  template:
    metadata:
      labels:
        name: fluentd
    spec:
      containers:
      - name: fluentd
        image: fluent/fluentd-kubernetes-daemonset:v1-debian-elasticsearch
        env:
        - name: FLUENT_ELASTICSEARCH_HOST
          value: "elasticsearch.logging.svc.cluster.local"
        - name: FLUENT_ELASTICSEARCH_PORT
          value: "9200"
        volumeMounts:
        - name: varlog
          mountPath: /var/log
        - name: varlibdockercontainers
          mountPath: /var/lib/docker/containers
          readOnly: true
        - name: fluentd-config
          mountPath: /fluentd/etc/fluent.conf
          subPath: fluent.conf
      volumes:
      - name: varlog
        hostPath:
          path: /var/log
      - name: varlibdockercontainers
        hostPath:
          path: /var/lib/docker/containers
      - name: fluentd-config
        configMap:
          name: fluentd-config
EOF

# Install Elasticsearch for log storage
helm repo add elastic https://helm.elastic.co
helm install elasticsearch elastic/elasticsearch \
  --namespace logging \
  --create-namespace \
  --set replicas=1 \
  --set minimumMasterNodes=1

# Install Kibana for log visualization
helm install kibana elastic/kibana \
  --namespace logging \
  --set elasticsearchHosts=http://elasticsearch-master:9200

# Check logging stack
kubectl get pods -n logging
kubectl get svc -n logging

# Access Kibana (port forward)
kubectl port-forward svc/kibana-kibana 5601:5601 -n logging

# Create monitoring dashboard
kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-dashboard
  namespace: monitoring
data:
  dashboard.json: |
    {
      "dashboard": {
        "title": "Kubernetes Cluster Monitoring",
        "panels": [
          {
            "title": "CPU Usage",
            "type": "graph",
            "targets": [
              {
                "expr": "100 - (avg(rate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100)"
              }
            ]
          },
          {
            "title": "Memory Usage",
            "type": "graph",
            "targets": [
              {
                "expr": "100 - ((node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) * 100)"
              }
            ]
          }
        ]
      }
    }
EOF

# Create alerting rules
kubectl apply -f - <<EOF
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: kubernetes-alerts
  namespace: monitoring
spec:
  groups:
  - name: kubernetes.rules
    rules:
    - alert: HighCPUUsage
      expr: 100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "High CPU usage detected"
        description: "CPU usage is above 80% for more than 5 minutes"
    
    - alert: HighMemoryUsage
      expr: 100 - ((node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) * 100) > 80
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "High memory usage detected"
        description: "Memory usage is above 80% for more than 5 minutes"
    
    - alert: PodCrashLoopBackOff
      expr: kube_pod_status_phase{phase="Running"} == 0 and kube_pod_status_phase{phase="Failed"} == 1
      for: 1m
      labels:
        severity: critical
      annotations:
        summary: "Pod in CrashLoopBackOff"
        description: "Pod {{ \$labels.pod }} is in CrashLoopBackOff state"
EOF

# Create ServiceMonitor for custom metrics
kubectl apply -f - <<EOF
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: custom-metrics
  namespace: monitoring
spec:
  selector:
    matchLabels:
      app: custom-metrics
  endpoints:
  - port: metrics
    interval: 30s
    path: /metrics
EOF

# Check monitoring stack status
kubectl get pods -n monitoring
kubectl get prometheusrules -n monitoring
kubectl get servicemonitors -n monitoring

# Test log collection
kubectl run test-logging --image=nginx --restart=Never
kubectl logs test-logging

# Check if logs are being collected
kubectl logs -n kube-system -l name=fluentd

# Create log retention policy
kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: log-retention-policy
  namespace: kube-system
data:
  retention.conf: |
    # Log retention policy
    # Keep logs for 30 days
    # Compress logs older than 7 days
    # Delete logs older than 30 days
EOF

# Set up log rotation
sudo tee /etc/logrotate.d/kubernetes << 'EOF'
/var/log/containers/*.log {
    daily
    rotate 30
    compress
    delaycompress
    missingok
    notifempty
    create 0644 root root
}
EOF

# Test log rotation
sudo logrotate -d /etc/logrotate.d/kubernetes

# Create monitoring script
sudo tee /usr/local/bin/cluster-health-check.sh << 'EOF'
#!/bin/bash
echo "=== Kubernetes Cluster Health Check ==="

# Check node status
echo "Node Status:"
kubectl get nodes

# Check pod status
echo -e "\nPod Status:"
kubectl get pods --all-namespaces | grep -v Running | grep -v Completed

# Check resource usage
echo -e "\nResource Usage:"
kubectl top nodes
kubectl top pods --all-namespaces | head -20

# Check events
echo -e "\nRecent Events:"
kubectl get events --sort-by=.metadata.creationTimestamp | tail -10

echo -e "\nHealth check completed"
EOF

# Make script executable
sudo chmod +x /usr/local/bin/cluster-health-check.sh

# Run health check
/usr/local/bin/cluster-health-check.sh

# Clean up test resources
kubectl delete pod test-logging
```

### Expected Outcomes
- Prometheus and Grafana installed and configured
- Centralized logging system operational
- Alerting rules configured and working
- Log retention policies implemented
- Monitoring dashboards created
