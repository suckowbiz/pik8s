# TROUBLESHOOT

- Issue: "kubeadm Module configs not found in directory"
  Solved with: restore Raspbian kernel `sudo apt install --reinstall raspberrypi-bootloader raspberrypi-kernel`
- Issue: docker pull calico/cni:v3.9.5
  There is no ARM release :(