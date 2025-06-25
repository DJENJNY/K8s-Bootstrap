#!/bin/bash

echo "Worker Node Setup"

cat /vagrant/hosts >> /etc/hosts

wget -q --show-progress \
  --https-only \
  --timestamping \
  -P /vagrant \
  -i /vagrant/downloads-$(dpkg --print-architecture).txt

{
  apt-get update
  apt-get -y install socat conntrack ipset kmod
}

swapoff -a

# Create the necessary directories
mkdir -p /var/lib/{kube-proxy,kubelet,kubernetes}

mkdir -p /etc/cni/net.d

mkdir -p /opt/cni/bin

mkdir -p /var/run/kubernetes

ARCH=$(dpkg --print-architecture)
tar -xvf /vagrant/crictl-v1.32.0-linux-${ARCH}.tar.gz -C /usr/local/bin/
tar -xvf /vagrant/containerd-2.1.0-beta.0-linux-${ARCH}.tar.gz --strip-components 1 -C /bin/
tar -xvf /vagrant/cni-plugins-linux-${ARCH}-v1.6.2.tgz -C /opt/cni/bin/

cp /vagrant/{kubelet,kube-proxy} /usr/local/bin/
cp /vagrant/runc.${ARCH} /usr/local/bin/

chmod +x /usr/local/bin/{runc.arm64,crictl,kube-proxy,kubectl}


# Copy the binaries to the appropriate directory
# {
#   # cp /vagrant/downloads/worker/kube-proxy /vagrant/downloads/worker/kubelet /vagrant/downloads/worker/runc \
#   #   /usr/local/bin/
#   # cp /vagrant/downloads/worker/containerd /vagrant/downloads/worker/containerd-shim-runc-v2 /vagrant/downloads/worker/containerd-stress /bin/
#   # cp /vagrant/downloads/cni-plugins/* /opt/cni/bin/
# }

# Copy the CNI configuration files to the appropriate directory
cp /vagrant/workers/$(hostname)/10-bridge.conf /vagrant/configs/99-loopback.conf /etc/cni/net.d/

# Load the br_netfilter kernel module
{
  modprobe br-netfilter
  echo "br-netfilter" >> /etc/modules-load.d/modules.conf
}

{
  echo "net.bridge.bridge-nf-call-iptables = 1" \
    >> /etc/sysctl.d/kubernetes.conf
  echo "net.bridge.bridge-nf-call-ip6tables = 1" \
    >> /etc/sysctl.d/kubernetes.conf
  sysctl -p /etc/sysctl.d/kubernetes.conf
}

# Copy the containerd configuration file to the appropriate directory
{
  mkdir -p /etc/containerd/
  cp /vagrant/configs/containerd-config.toml /etc/containerd/config.toml
  cp /vagrant/units/containerd.service /etc/systemd/system/
}

# Copy the kubelet configuration file to the appropriate directory
{
  cp /vagrant/configs/kubelet-config.yaml /var/lib/kubelet/
  cp /vagrant/units/kubelet.service /etc/systemd/system/
}

# Copy the kube-proxy configuration file to the appropriate directory
{
  cp /vagrant/configs/kube-proxy-config.yaml /var/lib/kube-proxy/
  cp /vagrant/units/kube-proxy.service /etc/systemd/system/
}

# Copy the CA certificate to the appropriate directory
cp /vagrant/ca.crt /var/lib/kubelet/ca.crt

# Copy the certificate to the appropriate directory
cp /vagrant/$(hostname).crt /var/lib/kubelet/kubelet.crt

cp /vagrant/$(hostname).key /var/lib/kubelet/kubelet.key

cp /vagrant/kube-proxy.kubeconfig /var/lib/kube-proxy/kubeconfig 

cp /vagrant/$(hostname).kubeconfig /var/lib/kubelet/kubeconfig

# Start the services
{
  systemctl daemon-reload
  systemctl enable containerd kubelet kube-proxy
  systemctl start containerd kubelet kube-proxy
}

NODE_NAME=$(hostname)

if [ "$NODE_NAME" = "node-1" ]; then
    echo "Running on node1"
    # Command for node1
    NODE_2_IP=$(grep node-2 /vagrant/machines.txt | cut -d " " -f 1)
    NODE_2_SUBNET=$(grep node-2 /vagrant/machines.txt | cut -d " " -f 4)
    ip route add ${NODE_2_SUBNET} via ${NODE_2_IP} dev enp0s3 onlink
elif [ "$NODE_NAME" = "node-2" ]; then
    echo "Running on node2"
    # Command for node2
    NODE_1_IP=$(grep node-1 /vagrant/machines.txt | cut -d " " -f 1)
    NODE_1_SUBNET=$(grep node-1 /vagrant/machines.txt | cut -d " " -f 4)
    ip route add ${NODE_1_SUBNET} via ${NODE_1_IP} dev enp0s3 onlink
else
    echo "Unknown node: $NODE_NAME"
    exit 1
fi

echo "Done"




