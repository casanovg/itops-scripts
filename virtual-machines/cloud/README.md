## Cloud server virtual machine

* A local iSCSI client (initiator) connects to 2 iSCSI drives (targets) on a physical server.
* [Seafile](http://seafile.com) is used to share files in the cloud.
* [Mattermost](http://mattermost.com) is used as a team communication tool (like slack).
* iSCSI drives are mounted inside the `/data` folder and support Seafile and Mattermost application data.
* This VM also runs [Nginx](http://nginx.org) as a web front-end and reverse proxy.
* Reverse proxy configuration allows routing HTTP requests to applications running on this VM and those running on other VMs.
* Nginx websites have [Let's Encrypt](http://letsencrypt.org) certificates to support HTTPS.
