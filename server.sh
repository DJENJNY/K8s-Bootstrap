#!/bin/bash

cat /vagrant/hosts >> /etc/hosts

# Download the etcd binaries
wget -q --show-progress \
  --https-only \
  --timestamping \
  -P /vagrant \
  -i /vagrant/downloads-$(dpkg --print-architecture).txt

mkdir -p /vagrant/downloads/{client,cni-plugins,controller,worker}

export ARCH=$(dpkg --print-architecture)
# Extract the etcd binaries
tar -xvf /vagrant/etcd-v3.6.0-rc.3-linux-${ARCH}.tar.gz \
    -C /vagrant/downloads/ \
    --strip-components 1 \
    etcd-v3.6.0-rc.3-linux-${ARCH}/etcdctl \
    etcd-v3.6.0-rc.3-linux-${ARCH}/etcd
    
cp /vagrant/downloads/etcdctl /usr/local/bin/
cp /vagrant/downloads/etcd /usr/local/bin/

rm -rf /vagrant/downloads/*gz

# Make the etcd binaries executable
chmod +x /usr/local/bin/{etcd,etcdctl}


# Install the etcd binaries
{
  mkdir -p /etc/etcd /var/lib/etcd
  chmod 700 /var/lib/etcd
  cp /vagrant/ca.crt /vagrant/kube-api-server.key /vagrant/kube-api-server.crt \
    /etc/etcd/
}

cp /vagrant/units/etcd.service /etc/systemd/system/

# Start the etcd service

systemctl daemon-reload
systemctl enable etcd
systemctl start etcd

# Create K8s Config Directory
mkdir -p /etc/kubernetes/config

# Install the Kubernetes binaries
cp /vagrant/{kube-apiserver,kube-controller-manager,kube-scheduler,kubectl} /usr/local/bin/

# Make the K8s binaries executable
chmod +x /usr/local/bin/{kube-apiserver,kube-controller-manager,kube-scheduler,kubectl}
chmod +x /vagrant/runc.arm64

# Create the Kubernetes configuration directory
mkdir -p /var/lib/kubernetes/

#Config K8s API Server
cp /vagrant/ca.crt /vagrant/ca.key \
    /vagrant/kube-api-server.key /vagrant/kube-api-server.crt \
    /vagrant/service-accounts.key /vagrant/service-accounts.crt \
    /vagrant/encryption-config.yaml \
    /var/lib/kubernetes/

#Created Kube-Apiserver system
cp /vagrant/units/kube-apiserver.service \
  /etc/systemd/system/kube-apiserver.service  

#Config Kube Controller Manager
cp /vagrant/kube-controller-manager.kubeconfig /var/lib/kubernetes/

cp /vagrant/units/kube-controller-manager.service /etc/systemd/system/

#Config K8s scheduler

cp /vagrant/kube-scheduler.kubeconfig /var/lib/kubernetes/

cp /vagrant/configs/kube-scheduler.yaml /etc/kubernetes/config/

cp /vagrant/units/kube-scheduler.service /etc/systemd/system/

#Start Services

systemctl daemon-reload

systemctl enable kube-apiserver \
    kube-controller-manager kube-scheduler

systemctl start kube-apiserver \
    kube-controller-manager kube-scheduler

NODE_2_IP=$(grep node-2 /vagrant/machines.txt | cut -d " " -f 1)
NODE_2_SUBNET=$(grep node-2 /vagrant/machines.txt | cut -d " " -f 4)
NODE_1_IP=$(grep node-1 /vagrant/machines.txt | cut -d " " -f 1)
NODE_1_SUBNET=$(grep node-1 /vagrant/machines.txt | cut -d " " -f 4)

ip route add ${NODE_2_SUBNET} via ${NODE_2_IP} dev enp0s3 onlink
ip route add ${NODE_1_SUBNET} via ${NODE_1_IP} dev enp0s3 onlink













