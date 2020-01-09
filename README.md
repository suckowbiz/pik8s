# README

This repository was created to deploy a **Kubernetes** (K8s) cluster on **Rasbperry Pi** boxes with **Ansible** for **testing purpose**.

## Prerequisites

- **Hardware**: Availability of 4 Raspberry Pi boxes (1 master, 3 worker) to be used as kubernetes nodes. It is assumed [Raspbian Buster](https://www.raspberrypi.org/downloads/raspbian/) is installed, SSH is running and Pi-to-Pi/Internet connectivity is in place.
- **Software**: Ansible Playbook >= 2.8.2 to deploy the cluster.

## Usage

Initial set up:

1. Enable SSH access to Raspberry Pi required for Ansible deployment (replace `<ip>` with Raspberry ip):

    ```bash
    # (If required generate local SSH key via: ssh-keygen)
    # Default password: 'raspberry'
    ssh-copy-id -o "StrictHostKeyChecking no" pi@<ip>
    ```
1. Edit hostnames in `./hosts.yaml` to enable Ansible host location.
1. Change api ip in `./group_vars/all/defaults.yaml` to configure the API announcement.
1. Replace `pi10.dmz.local` at line `k8s_token: "{{ hostvars['pi10.dmz.local']['token_result'].stdout }}"` in `./k8s-create.yaml` with the hostname of the master node to fetch a Kubernetes token for worker registration.

### Create K8s Cluster

Run:

```bash
ansible-playbook k8s-create.yaml
```

### Delete K8s Cluster

Run:

```bash
ansible-playbook k8s-destroy.yaml
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
# Requires kubectl
./smoke-test.sh
```

## Resources

- ebook [Kubernetes.Up.and.Running.Free.Copy.pdf](https://azure.microsoft.com/en-us/resources/kubernetes-up-and-running/)
- [official documentation](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm)
- [https://github.com/kelseyhightower/kubernetes-the-hard-way](https://github.com/kelseyhightower/kubernetes-the-hard-way)