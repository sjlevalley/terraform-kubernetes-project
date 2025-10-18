# Install Container Runtime

## Task: Install and Configure Container Runtime

### Scenario
You need to install and configure a container runtime (containerd or Docker) on your Kubernetes nodes.

### Tasks
1. **Install container runtime**
   - Install containerd or Docker
   - Configure runtime settings
   - Start and enable services

2. **Configure runtime for Kubernetes**
   - Set up systemd cgroup driver
   - Configure logging and storage
   - Test container creation

3. **Troubleshoot runtime issues**
   - Check runtime status
   - Debug container failures
   - Verify runtime configuration

### Commands to Practice
```bash
# Install containerd
sudo apt-get update
sudo apt-get install -y containerd

# Configure containerd
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml

# Configure systemd cgroup driver
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

# Restart containerd
sudo systemctl restart containerd
sudo systemctl enable containerd

# Install Docker (alternative)
sudo apt-get update
sudo apt-get install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker

# Configure Docker for Kubernetes
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

# Restart Docker
sudo systemctl restart docker

# Test container runtime
sudo ctr images pull docker.io/library/nginx:latest
sudo docker run --rm hello-world

# Check runtime status
sudo systemctl status containerd
sudo systemctl status docker
```

### Expected Outcomes
- Container runtime installed and running
- Systemd cgroup driver configured
- Services enabled and started
- Container creation working
