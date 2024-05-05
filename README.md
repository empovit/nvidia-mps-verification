## Troubleshooting SELinux

1. Open a debug session on the node:

   ```console
   $ oc debug node/<node>
   ```

2. Temporarily disable _dontaudit_ rules, allowing all denials to be logged:

   ```console
   # semodule -DB
   ```

3. Temporarily enable full-path auditing:

   ```console
   # auditctl -w /etc/shadow -p w -k shadow-write
   ```

4. Perform the actions you think are denied by SELinux.

5. Run `ausearch`:

   ```console
   # ausearch -m AVC,USER_AVC,SELINUX_ERR,USER_SELINUX_ERR -ts recent
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
   sh-5.1# audit2why
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
   # audit2allow
   ----
   time->Sun Apr 21 11:33:12 2024
   type=PROCTITLE msg=audit(1713699192.296:14033): proctitle=2F7573722F62696E2F6463676D70726F667465737465723132002D2D6E6F2D6463676D2D76616C69646174696F6E002D740031303034002D6400333030
   type=SYSCALL msg=audit(1713699192.296:14033): arch=c000003e syscall=47 success=yes exit=9 a0=d a1=7ffcbbe93dd0 a2=40000000 a3=7fc078e936e8 items=0 ppid=313405 pid=313500 auid=4294967295 uid=1000690000 gid=0 euid=1000690000 suid=1000690000 fsuid=1000690000 egid=0 sgid=0 fsgid=0 tty=(none) ses=4294967295 comm="dcgmproftester1" exe="/usr/bin/dcgmproftester12" subj=system_u:system_r:container_t:s0:c20,c26 key=(null)
   type=AVC msg=audit(1713699192.296:14033): avc:  denied  { read write } for  pid=313500 comm="dcgmproftester1" path="socket:[2709260]" dev="sockfs" ino=2709260 scontext=system_u:system_r:container_t:s0:c20,c26 tcontext=system_u:system_r:spc_t:s0 tclass=unix_stream_socket permissive=0


   #============= container_t ==============
   allow container_t spc_t:unix_stream_socket { read write };

8. [Build and install](https://www.ibm.com/docs/en/cloud-paks/cp-data/4.8.x?topic=storage-creating-selinux-policy-module) an SELinux module on the OpenShift node from the [mps_socket.te](./mps_socket.te) type enforcement file:

   ```console
   # checkmodule -M -m -o mps_socket.mod mps_socket.te
   # semodule_package -o mps_socket.pp -m mps_socket.mod
   # semodule -i mps_socket.pp
   ```

## Useful Resources

* [RHEL 9: Troubleshooting problems related to SELinux](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html/using_selinux/troubleshooting-problems-related-to-selinux_using-selinux)
* [RHEL 9: Writing a custom SELinux policy](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html/using_selinux/writing-a-custom-selinux-policy_using-selinux)
* [RHEL 9: Chapter 9. Creating SELinux policies for containers](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html/using_selinux/creating-selinux-policies-for-containers_using-selinux)
* [Quick start to write a custom SELinux policy](https://access.redhat.com/articles/6999267)
* [RHEL Audit System Reference](https://access.redhat.com/articles/4409591)
* [OpenShift Container Platform 4.15: Security and Compliance](https://docs.openshift.com/container-platform/4.15/security/index.html)