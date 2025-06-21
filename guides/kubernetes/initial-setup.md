# Kubernetes install and setup

This project uses K3S to simplify Kubernetes installation process. As the tool uses `iptables` utility to handle nodes communication, it must be installed (the Debian installations used didn't had the package by default) and enabled on them:

```sh
sudo apt install iptables -y && sudo iptables -F
```

The enabling of the tool requires to reboot the system

> [!IMPORTANT]
>
> Next steps should be done from the root account (`su -` and use root password)

## Control Plane installation

K3S provides commands for straightforward installs, both for the Control Plane and the worker nodes. For the first case:

```sh
curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" sh -s -
```

Where "644" mode is an optional setup to install Rancher, a web GUI for cluster visualization and management.

> [!NOTE]
>
> At the time of the project, the stable release was v1.32.5+k3s1

For a quick health check of the cluster, standard `kubectl` can be used

```sh
kubectl get nodes
```

It should output a single node as the Control Plane

### Access token

In order to registry the worker nodes, K3S uses access an token that must be provided to them on install time. The token can be obtained from the driver with

```sh
cat /var/lib/rancher/k3s/server/node-token
```

## Worker node installation

The base command is the same, but additional configuration is required to register with the driver:

```sh
curl -sfL https://get.k3s.io | K3S_TOKEN="<control plane token" K3S_URL="https://<control plane ip>:6443" K3S_NODE_NAME="<name for this node>" sh -
```

> [!TIP]
> The Control Plane's IP address would be the one set to be the static address of the corresponding machine
> 

> [!IMPORTANT]
>
> Each worker should have an unique name
