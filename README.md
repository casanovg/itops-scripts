# IT operations scripts
Various Bash scripts to run services, [VirtualBox](http://virtualbox.org) machines, backups, etc. in a [Fedora-based](http://getfedora.org) on-premise server environment.

After installing a new physical server or virtual machine:

1. Login with an account with administrative permissions (belonging to the wheel group) and run: `$ git clone https://github.com/casanovg/itops-scripts.git`.

2. Configure configure the GitHub account to activate the scripts' synchronization: `$ ~/itops-scripts/utils/git-update-id.sh`.

3. Make sure that the cron service is activated, and edit the crontab file: `$ crontab -e`. For this, it is convenient to copy and adapt some of the example [crontab configurations](./cron) for physical servers or virtual machines.
