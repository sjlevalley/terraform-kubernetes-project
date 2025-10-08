
# Step 01 - Setup & Installing Kubeadm

**Run the following command on all 3 Nodes (from the 'Installing Kubeadm' page)**
***Note that the 'machines.txt' file in theh root directory has the commands to SSH into the master node, as well as the two worker nodes.

**Set up terminals in each of the 3 Nodes (master, node-0, node-1)**
`ssh -i "k8s-key.pem" admin@<NODE_IP>`

**Verify which distribution of Linux you're using**
`sudo cat /etc/*release*`

**Get the Public Signing Key for the Kubernetes Package Repositories**
- Go to the following page [Installing Kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)
- Select which version of Kubeadm you want to install (we will do v1.31) and click on the link.

**Download the Public Signing Key for the Kubernetes package repositories based on the distribution of Linux that is in use (We will use Debian)**


***DO ON ALL NODES***
```bash
{
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
}
```

***DO ON ALL NODES***
- Note: If the above curl command fails, run this command, then run the curl command again. 
`sudo mkdir -p -m 755 /etc/apt/keyrings`

***DO ON ALL NODES***
`echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list`


***DO ON ALL NODES***
```bash
{
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
}
```

***DO ON ALL NODES***
**Verify Installation**
```bash
{
kubeadm version
kubectl version --client
kubelet --version
}
```

<!-- Now you can proceed to the 'Creating A Cluster' page on the Kubeernetes documentation website -->
