**UNCOMMENT THE SECTION FOR THE CNI PLUGIN YOU WISH TO INSTALL


***FLANNEL***

# To install Flannel on this cluster, you must first do the following
***RUN ON ALL NODES***
```bash
sudo modprobe br_netfilter # Load the br_netfilter module
echo 'br_netfilter' | sudo tee -a /etc/modules # Make it permanent
echo 'net.bridge.bridge-nf-call-iptables = 1' | sudo tee -a /etc/sysctl.d/kubernetes.conf # Configure bridge settings
echo 'net.bridge.bridge-nf-call-ip6tables = 1' | sudo tee -a /etc/sysctl.d/kubernetes.conf # Configure bridge settings
sudo sysctl -p /etc/sysctl.d/kubernetes.conf # Apply the settings
```

# Install CNI plugins (required for Flannel to work)
***RUN ON ALL NODES***
```bash
sudo mkdir -p /opt/cni/bin
cd /tmp
wget https://github.com/containernetworking/plugins/releases/download/v1.3.0/cni-plugins-linux-amd64-v1.3.0.tgz
sudo tar -xzf cni-plugins-linux-amd64-v1.3.0.tgz -C /opt/cni/bin/

# Create symlink so Kubernetes can find CNI plugins
sudo mkdir -p /usr/lib/cni
sudo ln -sf /opt/cni/bin/* /usr/lib/cni/
```



# Then run the following command to set up Flannel on the Master Node
****Link to reference [Deploying Flannel Manually](https://github.com/flannel-io/flannel#deploying-flannel-manually)****
```bash
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
```


*****Verify Flannel Pods are running*****
`k get pods -A`

You should now see a 'kube-flannel...' pod in the 'kube-flannel' namespace 