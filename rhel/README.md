# How to run MPS on Red Hat Enterprise Linux (RHEL) without OpenShift

Reference: [NVIDIA Multi-Process Service](https://docs.nvidia.com/deploy/mps/).

1. Install NVIDIA drivers and CUDA. E.g. for [Red Hat Enterprise Linux]:
   [drivers](https://docs.nvidia.com/datacenter/tesla/driver-installation-guide/index.html#preparation),
   [CUDA](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/#rhel-rocky-installation).

2. (Optionally) Set `CUDA_MPS_PIPE_DIRECTORY` if you don't want to use the default `/tmp/nvidia-mps`.

3. (Optionally) Set other [environment variable](https://docs.nvidia.com/deploy/mps/#environment-variables),
   e.g. default MPS server parameters:

   ```console
   export CUDA_MPS_ACTIVE_THREAD_PERCENTAGE=25
   ```

   ```console
   export CUDA_MPS_PINNED_DEVICE_MEM_LIMIT=''0=10GB''
   ```

4. (Optionally) Configure MPS, e.g. default thread percentage.

   **Important**: This must be done before an MPS server is started by the control daemon.

   ```console
   echo set_default_active_thread_percentage 25 | nvidia-cuda-mps-control
   ```

   and verify it:

   ```console
   echo get_default_active_thread_percentage | nvidia-cuda-mps-control
   ```

5. Start the MPS control daemon. Use `-f` to run it in the foreground to see what's going on.
   In this case, you'll need to open multiple terminal windows to interact with MPS.

   ```console
   nvidia-cuda-mps-control -f
   ```

6. Run clients.

7. Observe client and server processes in `nvidia-smi`, e.g.

   ```console
   watch -n5 nvidia-smi
   ```

8. Shut down the control daemon.
   If it runs in the background, send `quit` command:

   ```console
   echo quit | nvidia-cuda-mps-control
   ```

## Appendix: Building and running [GPU Burn](https://github.com/wilicc/gpu-burn) on RHEL 9

```console
## Enables repos and install dependencies
sudo subscription-manager register
sudo subscription-manager repos --enable=rhel-9-for-x86_64-appstream-rpms
sudo subscription-manager repos --enable=rhel-9-for-x86_64-baseos-rpms
sudo subscription-manager repos --enable=codeready-builder-for-rhel-9-x86_64-rpms
sudo rpm --erase gpg-pubkey-7fa2af80*
sudo dnf config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/rhel9/x86_64/cuda-rhel9.repo
sudo dnf clean all
sudo dnf clean expire-cache
sudo dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
sudo dnf install -y git make g++ kernel-devel-matched kernel-headers cuda-toolkit nvidia-driver-cuda

# For proprietary kernel modules
sudo dnf module install nvidia-driver:latest-dkms
sudo dnf insatll -y kmod-nvidia-latest-dkms

# For open kernel modules
# sudo dnf module -y install nvidia-driver:open-dkms
# sudo dnf install -y kmod-nvidia-open-dkms

# Reboot (optional)
# sudo reboot

## Build and GPU Burn
git clone https://github.com/wilicc/gpu-burn.git
cd gpu-burn
make
./gpu-burn
```

