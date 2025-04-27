# Building and running [GPU Burn](https://github.com/wilicc/gpu-burn) on RHEL 9 with MPS

Demonstrate MPS on RHEL 9, server and client configuration, and behavior.

1. Enable repos and install dependencies:

```console
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
sudo dnf install -y kmod-nvidia-latest-dkms

# For open kernel modules
# sudo dnf module -y install nvidia-driver:open-dkms
# sudo dnf install -y kmod-nvidia-open-dkms
```

2. Reboot may be required.

3. Set MPS pipe and log directories:

```console
mkdir ~/mps-pipe
mkdir ~/mps-logs

export CUDA_MPS_PIPE_DIRECTORY=~/mps-pipe
export CUDA_MPS_LOG_DIRECTORY=~/mps-logs
```

4. Start the control daemon in the foreground (`-f`):

```console
nvidia-cuda-mps-control -f
```

5. _In a new window_, build GPU Burn:

```console
git clone https://github.com/wilicc/gpu-burn.git
cd gpu-burn
make
```

6. Set MPS pipe directory:

```console
export CUDA_MPS_PIPE_DIRECTORY=~/mps-pipe
```

7. Run a client to trigger the creation of a MPS server (for 30 sec):

```console
./gpu_burn 30
```

Watch the client using up all available memory in `nvidia-smi` (in a separate window).
Notice the MPS server process and the client process type `M+C`.

```console
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 570.133.20             Driver Version: 570.133.20     CUDA Version: 12.8     |
|-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  Tesla V100-SXM2-32GB           Off |   00000000:09:00.0 Off |                    0 |
| N/A   41C    P0            297W /  300W |   29277MiB /  32768MiB |    100%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+

+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI              PID   Type   Process name                        GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
|    0   N/A  N/A           43436      C   nvidia-cuda-mps-server                   30MiB |
|    0   N/A  N/A           43462    M+C   ./gpu_burn                            29244MiB |
+-----------------------------------------------------------------------------------------+
```

8. Find out PID of the MPS server process:

```console
mps_server_pid=$(echo get_server_list | nvidia-cuda-mps-control)
```

9. Configure device pinned memory limit, e.g. 10GB on a 32GB card:

```console
echo set_device_pinned_mem_limit $mps_server_pid 0 10GB | nvidia-cuda-mps-control
```

10. Run the client again and watch it this time use up to the allowed memory limit (e.g. 10GB):

```console
./gpu_burn 30
```

```console
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 570.133.20             Driver Version: 570.133.20     CUDA Version: 12.8     |
|-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  Tesla V100-SXM2-32GB           Off |   00000000:09:00.0 Off |                    0 |
| N/A   44C    P0            295W /  300W |    9053MiB /  32768MiB |    100%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+

+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI              PID   Type   Process name                        GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
|    0   N/A  N/A           43436      C   nvidia-cuda-mps-server                   30MiB |
|    0   N/A  N/A           43493    M+C   ./gpu_burn                             9020MiB |
+-----------------------------------------------------------------------------------------+
```

11. Try to run multiple clients in parallel, when their number times pinned memory limit exceeds the total GPU memory (e.g. 4x10GB=40GB on a 32GB card):

```console
nohup ./gpu_burn 60 &
nohup ./gpu_burn 60 &
nohup ./gpu_burn 60 &
nohup ./gpu_burn 60 &
```

If memory was allocated, only three clients could have run (3x10GB = 32GB).
However, all four clients can run, some getting less memory than the others,
but none takes more than the limit of 10GB.

```console
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 570.133.20             Driver Version: 570.133.20     CUDA Version: 12.8     |
|-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  Tesla V100-SXM2-32GB           Off |   00000000:09:00.0 Off |                    0 |
| N/A   50C    P0            300W /  300W |   31761MiB /  32768MiB |    100%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+

+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI              PID   Type   Process name                        GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
|    0   N/A  N/A           43436      C   nvidia-cuda-mps-server                   30MiB |
|    0   N/A  N/A           43521    M+C   ./gpu_burn                             9020MiB |
|    0   N/A  N/A           43534    M+C   ./gpu_burn                             9020MiB |
|    0   N/A  N/A           43545    M+C   ./gpu_burn                             9020MiB |
|    0   N/A  N/A           43552    M+C   ./gpu_burn                             4668MiB |
+-----------------------------------------------------------------------------------------+
```

Note that some clients may fail, presumably because of out-of-memory.

12. If a client uses less than the allotted memory (e.g. 70%), MPS will not prevent other clients from using the unused memory
even though the pinned memory limit is still 10GB:

```console
nohup ./gpu_burn -m 70% 60 &
nohup ./gpu_burn -m 70% 60 &
nohup ./gpu_burn -m 70% 60 &
nohup ./gpu_burn -m 70% 60 &
nohup ./gpu_burn -m 70% 60 &
```

```console
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 570.133.20             Driver Version: 570.133.20     CUDA Version: 12.8     |
|-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  Tesla V100-SXM2-32GB           Off |   00000000:09:00.0 Off |                    0 |
| N/A   51C    P0            294W /  300W |   30797MiB /  32768MiB |    100%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+

+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI              PID   Type   Process name                        GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
|    0   N/A  N/A           43436      C   nvidia-cuda-mps-server                   30MiB |
|    0   N/A  N/A           43696    M+C   ./gpu_burn                             2108MiB |
|    0   N/A  N/A           43697    M+C   ./gpu_burn                             7228MiB |
|    0   N/A  N/A           43698    M+C   ./gpu_burn                             7228MiB |
|    0   N/A  N/A           43700    M+C   ./gpu_burn                             7228MiB |
|    0   N/A  N/A           43706    M+C   ./gpu_burn                             6972MiB |
+-----------------------------------------------------------------------------------------+
```

13. Variable memory limits, per client:

Define a `CUDA_MPS_PINNED_DEVICE_MEM_LIMIT` per client, e.g. 10GB, 5GB and 15GB (on a 32GB GPU):

```console
export CUDA_MPS_PINNED_DEVICE_MEM_LIMIT=''0=10GB''
nohup ./gpu_burn 120 &

export CUDA_MPS_PINNED_DEVICE_MEM_LIMIT=''0=5GB''
nohup ./gpu_burn 120 &

export CUDA_MPS_PINNED_DEVICE_MEM_LIMIT=''0=15GB''
nohup ./gpu_burn 120 &
```

MPS is enforcing the memory limit for each client:

```console
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 570.133.20             Driver Version: 570.133.20     CUDA Version: 12.8     |
|-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  Tesla V100-SXM2-32GB           Off |   00000000:09:00.0 Off |                    0 |
| N/A   47C    P0            299W /  300W |   27093MiB /  32768MiB |	100%	  Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+

+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI              PID   Type   Process name                        GPU Memory |
|        ID   ID                                                               Usage	  |
|=========================================================================================|
|    0   N/A  N/A           44789      C   nvidia-cuda-mps-server                   30MiB |
|    0   N/A  N/A           45022    M+C   ./gpu_burn                             4412MiB |
|    0   N/A  N/A           45029    M+C   ./gpu_burn                            13628MiB |
|    0   N/A  N/A           45032    M+C   ./gpu_burn                             9020MiB |
+-----------------------------------------------------------------------------------------+
```
