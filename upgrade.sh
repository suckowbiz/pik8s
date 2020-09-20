#!/usr/bin/env bash

cd ./ansible || echo "error moving into ./ansible directory"
ansible-playbook ./k8s-upgrade.yaml