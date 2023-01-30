## Fileserver virtual machine

* A local iSCSI client (initiator) connects to 2 iSCSI disks (targets) on a physical server.
* Both iSCSI disks are shared through [Samba](http://samba.org).
* Samba is integrated with Active Directory which runs over Windows Server 2016 domain controllers.
* All physical servers' important folders are mounted into this VM for backing them up.
* All important folders from other servers are mounted to the `/mnt-backintime` folder of this virtual machine for backup.
* The connection to the physical servers is made through sshfs.
* The backups are made with [Back In Time](https://github.com/bit-team/backintime) (rsync), installed in this VM.
