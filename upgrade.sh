#!/usr/bin/env bash

# Cluster upgrade requires special attention
cd ./ansible || echo "error moving into ./ansible directory"
ansible-playbook ./k8s-upgrade.yaml
# Apply idempotent updates such as os system upgrades.
ansible-playbook ./k8s-install.yaml