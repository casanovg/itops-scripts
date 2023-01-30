## Physical machines

These scripts are common to all [Fedora Server](http://getfedora.org) physical machines and automate on-premise operations using cron:
* [pfSense firewall](http://pfsense.org) virtual machine activation on one physical server, with automatic activation on another as a backup in case of loss of Internet access.
* Activation of all [Virtualbox](http://virtualbox.org) virtual machines after the physical server boot.
* Backup of all virtual machines.
* Server operating system update.
* Firewall VM configuration synchronization between physical servers.
* There are also scripts for manual operations like cloning and moving virtual machines from one server to another, etc.
