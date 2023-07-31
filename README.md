
# Vagrantfile and Scripts to Automate Kubernetes with Cilium setup using Kubeadm

The purpose of this repo is to create a demo/verification environment for Kubernetes with Cilium on Apple Silicon Macs with Darwin OS. It leverages Vagrant and Parallels as a virtual machine host provider.

This repo is based on the work found in:
 * https://github.com/ahmadjubair33/vagrant-kubernetes
 * https://computingforgeeks.com/install-kubernetes-cluster-ubuntu-jammy/
 * https://app.vagrantup.com/jharoian3/boxes/ubuntu-22.04-arm64


## Preparation

Install Parallels, Vagrant and the Parallels provider plugin:

```
brew install vagrant
brew install cilium-cli
vagrant plugin install vagrant-parallels
vagrant plugin list
```

## The architecture of the solution

The infrastructure that is being deployed consists of:

 * one control-plane node; untainted so it can be use also as a worker
 * two dedicated worker nodes
 * no-kube-proxy Cillium installation

## Run it

To invoke the creation of the said infraastructure do

```
vagrant up
export KUBECONFIG=$PWD/config
kubectl get nodes
```

Install the cilium tools with brew, verify it is operational and connect to the Hubble UI in your browser.
```
cilium status
cilium hubble ui
```

In another console run the connectivity test and switch to the Hublle UI. Monitor the `cilium-test` namespace for the tests execution.
```
cilium connectivity test
```



## Install Metric Server
```
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```
