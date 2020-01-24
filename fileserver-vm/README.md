## File Server virtual machine

* A local iSCSI client (initiator) connects to 2 iSCSI disks (targets) on a bare-metal server.
* Both iSCSI disks are shared through Samba.
* Samba is integrated with Active Directory which runs over Windows Server 2016 domain controllers.
* All bare-metal servers' important folders are mounted into this VM for backing them up.
* The connection to the bare-metal servers is made through sshfs.
* The backups are made with Back-In-Time (rsync), installed in this VM.
