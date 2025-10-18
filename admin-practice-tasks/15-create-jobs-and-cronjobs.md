# Create Jobs and CronJobs

## Task: CKAD - Batch Workload Management

### Scenario
You need to create and manage batch workloads using Jobs and CronJobs.

### Tasks
1. **Create Jobs**
   - Create one-time batch job
   - Configure job parallelism
   - Handle job completion and failure

2. **Create CronJobs**
   - Schedule recurring tasks
   - Configure cron schedule
   - Manage job history

3. **Monitor and troubleshoot**
   - Check job status and logs
   - Debug failed jobs
   - Clean up completed jobs

### Commands to Practice
```bash
# Create simple Job
kubectl apply -f - <<EOF
apiVersion: batch/v1
kind: Job
metadata:
  name: pi-job
spec:
  template:
    spec:
      containers:
      - name: pi
        image: perl
        command: ["perl", "-Mbignum=bpi", "-wle", "print bpi(2000)"]
      restartPolicy: Never
  backoffLimit: 4
EOF

# Create parallel Job
kubectl apply -f - <<EOF
apiVersion: batch/v1
kind: Job
metadata:
  name: parallel-job
spec:
  parallelism: 3
  completions: 6
  template:
    spec:
      containers:
      - name: worker
        image: busybox
        command: ["sh", "-c", "echo Processing item \$JOB_COMPLETION_INDEX; sleep 10"]
      restartPolicy: Never
  backoffLimit: 4
EOF

# Create CronJob
kubectl apply -f - <<EOF
apiVersion: batch/v1
kind: CronJob
metadata:
  name: backup-job
spec:
  schedule: "0 2 * * *"  # Daily at 2 AM
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: busybox
            command:
            - /bin/sh
            - -c
            - echo "Running backup at $(date)"
          restartPolicy: OnFailure
      backoffLimit: 2
  successfulJobsHistoryLimit: 3
  failedJobsHistoryLimit: 1
EOF

# Check Job status
kubectl get jobs
kubectl describe job pi-job

# Check CronJob status
kubectl get cronjobs
kubectl describe cronjob backup-job

# Check Job logs
kubectl logs job/pi-job

# Check CronJob logs
kubectl get jobs -l job-name=backup-job
kubectl logs job/backup-job-<timestamp>

# Suspend CronJob
kubectl patch cronjob backup-job -p '{"spec":{"suspend":true}}'

# Resume CronJob
kubectl patch cronjob backup-job -p '{"spec":{"suspend":false}}'

# Delete completed Jobs
kubectl delete jobs --field-selector status.successful=1

# Delete failed Jobs
kubectl delete jobs --field-selector status.failed=1
```

### Expected Outcomes
- Jobs created and completed successfully
- CronJobs scheduled and running
- Job monitoring and troubleshooting working
- Job cleanup performed
