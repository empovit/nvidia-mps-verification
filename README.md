# NVIDIA MPS on Red Hat OpenShift with the NVIDIA GPU Operator

This document describe the procedure for basic sanity testing of
[NVIDIA Multi-Process Service (MPS)](https://docs.nvidia.com/deploy/mps/)
on Red Hat OpenShift, and includes useful scripts.

**Warning**: Some of the scripts assume a single-node cluster -
Single-Node OpenShift (SNO) or OpenShift Local (aka CRC). Be careful.

## Running the example

1. Install the NFD Operator:

```console
./install-nfd-operator.sh
```

2. Install the NVIDIA GPU Operator:

```console
./install-gpu-operator.sh
```

3. Run a sample workload:

```console
oc apply -f workloads/dcgmproftester12-deployment-nonprivileged.yaml
```

4. Make sure the pods are running:

```console
oc get pod -n mps-np
```

```console
NAME                                  READY   STATUS    RESTARTS   AGE
nvidia-plugin-test-665d6f5c58-42tgg   1/1     Running   0          21s
nvidia-plugin-test-665d6f5c58-4jfjm   1/1     Running   0          21s
nvidia-plugin-test-665d6f5c58-hc4zq   1/1     Running   0          21s
nvidia-plugin-test-665d6f5c58-lnvcf   1/1     Running   0          21s
nvidia-plugin-test-665d6f5c58-tgbj6   1/1     Running   0          21s
```

5. Observe the processes with `nvidia-smi`. Notice the `M+C` type and the MPS server:

```console
./nvidia-smi.sh
```

```console
Wed Aug 14 14:48:14 2024
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 550.90.07              Driver Version: 550.90.07      CUDA Version: 12.4     |
|-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  NVIDIA A100-PCIE-40GB          On  |   00000000:06:00.0 Off |                    0 |
| N/A   56C    P0            244W /  250W |    2323MiB /  40960MiB |    100%   E. Process |
|                                         |                        |             Disabled |
+-----------------------------------------+------------------------+----------------------+

+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI        PID   Type   Process name                              GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
|    0   N/A  N/A    120344      C   nvidia-cuda-mps-server                         30MiB |
|    0   N/A  N/A    130275    M+C   /usr/bin/dcgmproftester12                     456MiB |
|    0   N/A  N/A    130276    M+C   /usr/bin/dcgmproftester12                     456MiB |
|    0   N/A  N/A    130281    M+C   /usr/bin/dcgmproftester12                     456MiB |
|    0   N/A  N/A    130284    M+C   /usr/bin/dcgmproftester12                     456MiB |
|    0   N/A  N/A    130286    M+C   /usr/bin/dcgmproftester12                     456MiB |
+-----------------------------------------------------------------------------------------+
```

Also, _on the node_, the pipe directory is expected to have the right SELinux label `container_file_t`:

```console
ls -Z1 /run/nvidia/mps/nvidia.com/gpu/
```

```console
system_u:object_r:container_var_run_t:s0 log
   system_u:object_r:container_file_t:s0 pipe
```

## Troubleshooting SELinux

1. Open a debug session on the node:

   ```console
   oc debug node/<node>
   ```

2. Temporarily disable _dontaudit_ rules, allowing all denials to be logged:

   ```console
   semodule -DB
   ```

3. Temporarily enable full-path auditing:

   ```console
   auditctl -w /etc/shadow -p w -k shadow-write
   ```

4. Perform the actions you think are denied by SELinux.

5. Run `ausearch`:

   ```console
   ausearch -m AVC,USER_AVC,SELINUX_ERR,USER_SELINUX_ERR -ts recent
   ```

   ```console
   ... skipped ...
   ----
   time->Sun Apr 21 11:33:12 2024
   type=PROCTITLE msg=audit(1713699192.296:14033): proctitle=2F7573722F62696E2F6463676D70726F667465737465723132002D2D6E6F2D6463676D2D76616C69646174696F6E002D740031303034002D6400333030
   type=SYSCALL msg=audit(1713699192.296:14033): arch=c000003e syscall=47 success=yes exit=9 a0=d a1=7ffcbbe93dd0 a2=40000000 a3=7fc078e936e8 items=0 ppid=313405 pid=313500 auid=4294967295 uid=1000690000 gid=0 euid=1000690000 suid=1000690000 fsuid=1000690000 egid=0 sgid=0 fsgid=0 tty=(none) ses=4294967295 comm="dcgmproftester1" exe="/usr/bin/dcgmproftester12" subj=system_u:system_r:container_t:s0:c20,c26 key=(null)
   type=AVC msg=audit(1713699192.296:14033): avc:  denied  { read write } for  pid=313500 comm="dcgmproftester1" path="socket:[2709260]" dev="sockfs" ino=2709260 scontext=system_u:system_r:container_t:s0:c20,c26 tcontext=system_u:system_r:spc_t:s0 tclass=unix_stream_socket permissive=0

6. Analyze the event:

   * Run audit2why
   * Paste the text
   * Press &lt;Ctrl-D&gt;

   ```console
   audit2why
   ```

   ```console
   ----
   time->Sun Apr 21 11:33:12 2024
   type=PROCTITLE msg=audit(1713699192.296:14033): proctitle=2F7573722F62696E2F6463676D70726F667465737465723132002D2D6E6F2D6463676D2D76616C69646174696F6E002D740031303034002D6400333030
   type=SYSCALL msg=audit(1713699192.296:14033): arch=c000003e syscall=47 success=yes exit=9 a0=d a1=7ffcbbe93dd0 a2=40000000 a3=7fc078e936e8 items=0 ppid=313405 pid=313500 auid=4294967295 uid=1000690000 gid=0 euid=1000690000 suid=1000690000 fsuid=1000690000 egid=0 sgid=0 fsgid=0 tty=(none) ses=4294967295 comm="dcgmproftester1" exe="/usr/bin/dcgmproftester12" subj=system_u:system_r:container_t:s0:c20,c26 key=(null)
   type=AVC msg=audit(1713699192.296:14033): avc:  denied  { read write } for  pid=313500 comm="dcgmproftester1" path="socket:[2709260]" dev="sockfs" ino=2709260 scontext=system_u:system_r:container_t:s0:c20,c26 tcontext=system_u:system_r:spc_t:s0 tclass=unix_stream_socket permissive=0
   type=AVC msg=audit(1713699192.296:14033): avc:  denied  { read write } for  pid=313500 comm="dcgmproftester1" path="socket:[2709260]" dev="sockfs" ino=2709260 scontext=system_u:system_r:container_t:s0:c20,c26 tcontext=system_u:system_r:spc_t:s0 tclass=unix_stream_socket permissive=0

   Was caused by:
           Missing type enforcement (TE) allow rule.

           You can use audit2allow to generate a loadable module to allow this access.
   ```

7. Generate the type enforcement rule:

   * Run audit2allow
   * Paste the text
   * Press &lt;Ctrl-D&gt;

   ```console
   audit2allow
   ```

   ```console
   ----
   time->Sun Apr 21 11:33:12 2024
   type=PROCTITLE msg=audit(1713699192.296:14033): proctitle=2F7573722F62696E2F6463676D70726F667465737465723132002D2D6E6F2D6463676D2D76616C69646174696F6E002D740031303034002D6400333030
   type=SYSCALL msg=audit(1713699192.296:14033): arch=c000003e syscall=47 success=yes exit=9 a0=d a1=7ffcbbe93dd0 a2=40000000 a3=7fc078e936e8 items=0 ppid=313405 pid=313500 auid=4294967295 uid=1000690000 gid=0 euid=1000690000 suid=1000690000 fsuid=1000690000 egid=0 sgid=0 fsgid=0 tty=(none) ses=4294967295 comm="dcgmproftester1" exe="/usr/bin/dcgmproftester12" subj=system_u:system_r:container_t:s0:c20,c26 key=(null)
   type=AVC msg=audit(1713699192.296:14033): avc:  denied  { read write } for  pid=313500 comm="dcgmproftester1" path="socket:[2709260]" dev="sockfs" ino=2709260 scontext=system_u:system_r:container_t:s0:c20,c26 tcontext=system_u:system_r:spc_t:s0 tclass=unix_stream_socket permissive=0


   #============= container_t ==============
   allow container_t spc_t:unix_stream_socket { read write };
   ```

8. [Build and install](https://www.ibm.com/docs/en/cloud-paks/cp-data/4.8.x?topic=storage-creating-selinux-policy-module) an SELinux module on the OpenShift node from the [mps_socket.te](./mps_socket.te) type enforcement file:

   ```console
   checkmodule -M -m -o mps_socket.mod mps_socket.te
   semodule_package -o mps_socket.pp -m mps_socket.mod
   semodule -i mps_socket.pp
   ```

## Useful Resources

* [RHEL 9: Troubleshooting problems related to SELinux](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html/using_selinux/troubleshooting-problems-related-to-selinux_using-selinux)
* [RHEL 9: Writing a custom SELinux policy](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html/using_selinux/writing-a-custom-selinux-policy_using-selinux)
* [RHEL 9: Chapter 9. Creating SELinux policies for containers](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html/using_selinux/creating-selinux-policies-for-containers_using-selinux)
* [Quick start to write a custom SELinux policy](https://access.redhat.com/articles/6999267)
* [RHEL Audit System Reference](https://access.redhat.com/articles/4409591)
* [OpenShift Container Platform 4.15: Security and Compliance](https://docs.openshift.com/container-platform/4.15/security/index.html)