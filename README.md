# README

This repository was created to deploy a **Kubernetes** (K8s) cluster on **Raspberry Pi** boxes with **Ansible** for **testing purpose**.

## Prerequisites

- **Hardware**: Availability of 4 Raspberry Pi boxes (1 master, 3 worker) to be used as Kubernetes nodes. It is assumed [Raspbian Buster](https://www.raspberrypi.org/downloads/raspbian/) is installed, SSH access is possible and Pi-to-Pi/Internet connectivity is in place.
- **Software**: Ansible Playbook >= 2.8.2 to deploy the cluster.

## Choices Made

1. Which provider should I use? A public or private cloud? Physical or virtual?  
   **Physical on Raspberry Pi's**
1. Which operating system should I use? Kubernetes runs on most operating systems (e.g. Debian, Ubuntu, CentOS, etc.), plus on container-optimized OSes (e.g. CoreOS, Atomic).  
   **Raspbian**
1. Which networking solution should I use? Do I need an overlay?  
   **Flannel**
1. Where should I run my etcd cluster?  
   **Together with the API at single master node**
1. Can I configure Highly Available (HA) head nodes?  
   **A single master node does not support HA**

## Usage

Initial set up:

1. Enable SSH access for each of the Raspberry Pi's required for Ansible deployment (replace `<ip>` with Raspberry ip):

    ```bash
    # (If required generate local SSH key via: ssh-keygen)
    # Default password: 'raspberry'
    ssh-copy-id -o "StrictHostKeyChecking no" pi@<ip>
    ```
1. Edit hostnames in `./ansible/hosts.yaml` to enable Ansible host location.
1. Change api ip in `./ansible/group_vars/all/defaults.yaml` to configure the API announcement.
1. Replace `pi10.dmz.local` at line `k8s_token: "{{ hostvars['pi10.dmz.local']['token_result'].stdout }}"` in `./ansible/k8s-create.yaml` with the hostname of the master node to fetch a Kubernetes token for worker registration.

### Create K8s Cluster

Note: Cluster creation assumes the nodes are free to use and involves host provisioning that:

- disables bluetooth
- disables wifi
- sets a random default passwort

Run:

```bash
./cluster-create.sh
```

### Delete K8s Cluster

Run:

```bash
./cluster-delete.sh
```

### API Access

To access the K8s API from remote:

```bash
mkdir -p $HOME/.kube
ssh pi@<control-plane-host> "sudo cat /etc/kubernetes/admin.conf" > $HOME/.kube/config
# kubectl get nodes
```

### Testing

To verify function of the Kubernetes cluster run:

```bash
# Ensure the 'admin.conf' was copied over as described above in "API ACCESS"
# Requires kubectl
./smoke-test.sh
```

## Resources

- ebook [Kubernetes.Up.and.Running.Free.Copy.pdf](https://azure.microsoft.com/en-us/resources/kubernetes-up-and-running/)
- [official documentation](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm)
- [https://github.com/kelseyhightower/kubernetes-the-hard-way](https://github.com/kelseyhightower/kubernetes-the-hard-way)
