# Step 02 - Install Container Runtime

*****Verifying the cgroup driver*****
- If the cgroup driver is NOT set to systemd, go tot the section in the Kubernetes documentaion that talks about 'Configuring the kubelet cgroup driver'. 
- Note that after v1.22, if no cgroup driver is set, it will default to systemd
- If needed, the documentation shows how to manually set it to be systemd usinig a configuration yaml file.

*****Setting the container runtime (containerd) cgroup driver to systemd*****
- Note that this step is not automatic and must be done. 
- Instructions can be found on the 'Container Runtimes > containerd page under the 'Configuring the systemd cgroup driver' section

 


```bash
{
sudo apt update
sudo apt install -y containerd
}
```


**Verify cgroup driver
`ps -p 1`
- Output should say systemd as is shown below
```
PID TTY          TIME CMD
      1 ?        00:00:02 systemd
```





***RUN ON ALL NODES***
# Run the following command to set the 'SystemdCgroup = true' on the /etc/containerd/config.toml file.
```bash
sudo tee /etc/containerd/config.toml > /dev/null << 'EOF'
version = 2

[plugins]
  [plugins."io.containerd.grpc.v1.cri"]
    [plugins."io.containerd.grpc.v1.cri".cni]
      bin_dir = "/usr/lib/cni"
      conf_dir = "/etc/cni/net.d"
    [plugins."io.containerd.grpc.v1.cri".containerd]
      [plugins."io.containerd.grpc.v1.cri".containerd.runtimes]
        [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
          runtime_type = "io.containerd.runc.v2"
          [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
            SystemdCgroup = true
  [plugins."io.containerd.internal.v1.opt"]
    path = "/var/lib/containerd/opt"
EOF
```

***RUN ON ALL NODES***
`sudo systemctl restart containerd`

**Verify containerd is running**
***RUN ON ALL NODES***
```bash
{ 
sudo systemctl status containerd
sudo systemctl is-active containerd
}
```


