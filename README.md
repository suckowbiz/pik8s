# README

This repository was created to deploy a **Kubernetes** (K8s) cluster on **Raspberry Pi** boxes with **Ansible** for **testing purpose**.

## Prerequisites

- **Hardware**: Availability of 4 Raspberry Pi boxes (1 master, 3 worker) to be used as Kubernetes nodes.
- **Software**: Ansible Playbook >= 2.8.2 to deploy the cluster.

## Choices Made

- Ubuntu 19.04
- kubeadm for cluster setup
- Calico as CNI
- Docker as CRE

## Prepare Raspberry Pi's

Download 19.10 Ubuntu here [https://ubuntu.com/download/raspberry-pi](https://ubuntu.com/download/raspberry-pi).

1. Mount SD card at workstation
1. Umount the partitions of SD card to avoid writing issues:

   ```bash
   umount /dev/sdb1
   umount /dev/sdb2
   ```

1. Flash the Ubuntu OS to SD card via:  

   ```bash
   xzcat ~/Downloads/ubuntu-18.04.3-preinstalled-server-arm64+raspi3.img.xz | sudo dd of=/dev/sdb bs=32M status=progress
   ```

1. Complete flashing SD card  

   ```bash
   sync
   ```

1. Eject SD card from workstation and insert into Raspberry Pi

## Usage

Initial set up:

1. Enable SSH access for each of the Raspberry Pi's required for Ansible deployment (replace `<ip>` with Raspberry ip):

    ```bash
    # (If required generate local SSH key via: ssh-keygen)
    # Default password: 'raspberry'
    ssh-copy-id -o "StrictHostKeyChecking no" pi@<ip>
    ```

1. Edit hostnames in `./ansible/hosts.yaml` to enable Ansible host location.
1. Adopt api host in `./ansible/group_vars/all/defaults.yaml` to set the master node.
1. Replace `pi10.dmz.local` at line `k8s_token: "{{ hostvars['pi10.dmz.local']['token_result'].stdout }}"` in `./ansible/k8s-create.yaml` with the hostname of the master node to fetch a Kubernetes token for worker registration.

### Create K8s Cluster

Run:

```bash
./create.sh
```

### Delete K8s Cluster

Run:

```bash
./delete.sh
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
- [https://alexbrand.dev/post/creating-a-kind-cluster-with-calico-networking/](https://alexbrand.dev/post/creating-a-kind-cluster-with-calico-networking/)