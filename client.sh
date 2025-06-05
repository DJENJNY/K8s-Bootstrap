#!/bin/bash


mkdir -p /var/lib/{kube-proxy,kubelet}

cp /vagrant/ca.crt /var/lib/kubelet/ca.crt

cp /vagrant/$(hostname).crt /var/lib/kubelet/kubelet.crt

cp /vagrant/$(hostname).key /var/lib/kubelet/kubelet.key

cp /vagrant/kube-proxy.kubeconfig /var/lib/kube-proxy/kubeconfig 

cp /vagrant/$(hostname).kubeconfig /var/lib/kubelet/kubeconfig




