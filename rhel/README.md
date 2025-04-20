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

6. Run clients. You can find example shell scripts in this directory.

7. Observe client and server processes in `nvidia-smi`, e.g.

   ```console
   watch -n5 nvidia-smi
   ```

8. Shut down the control daemon.
   If it runs in the background, send `quit` command:

   ```console
   echo quit | nvidia-cuda-mps-control
   ```