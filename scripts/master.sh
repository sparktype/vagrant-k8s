#! /bin/bash

MASTER_IP="10.1.0.10"
NODENAME=$(hostname -s)
POD_CIDR="192.168.0.0/16"
KUBERNETES_VERSION="1.28.4"
CILIUM_VERSION="1.14.0"

# Pull the kubernetes images
sudo kubeadm config images pull 

# Init Kubernetes
sudo kubeadm init \
--skip-phases=addon/kube-proxy \
--apiserver-advertise-address=$MASTER_IP  \
--apiserver-cert-extra-sans=$MASTER_IP \
--pod-network-cidr=$POD_CIDR \
--node-name $NODENAME

# KUBECONFIG for in-VM kubectl usage
mkdir -p $HOME/.kube
sudo cp -f /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Untaint the control node to be used as a worker too
#kubectl taint nodes --all node-role.kubernetes.io/master-
kubectl taint nodes --all  node-role.kubernetes.io/control-plane-

# Install helm
sudo snap install helm --classic

# Install Cilium wiht its helm chart
helm repo add cilium https://helm.cilium.io/
helm install cilium cilium/cilium \
    --version $CILIUM_VERSION \
    --namespace kube-system \
    --set kubeProxyReplacement=strict \
    --set k8sServiceHost=$MASTER_IP \
    --set k8sServicePort=6443   \
    --set hubble.listenAddress=":4244" \
    --set hubble.relay.enabled=true \
    --set hubble.ui.enabled=true

# Generete KUBECONFIG on the host
sudo cp -f /etc/kubernetes/admin.conf /vagrant/config

# Generete the kubeadm join command on the host
kubeadm token create --print-join-command | sudo tee /vagrant/join.sh
sudo chmod +x /vagrant/join.sh