#!/bin/bash


mkdir /var/lib/kubelet/

cp /vagrant/ca.crt /var/lib/kubelet/ca.crt

cp /vagrant/$(hostname).crt /var/lib/kubelet/kubelet.crt

cp /vagrant/$(hostname).key /var/lib/kubelet/kubelet.key
