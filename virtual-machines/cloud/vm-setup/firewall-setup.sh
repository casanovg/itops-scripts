
sudo firewall-cmd --zone=public --permanent --add-port=8000/tcp
sudo firewall-cmd --zone=public --permanent --add-port=8000/udp
sudo firewall-cmd --zone=public --permanent --add-port=8082/tcp
sudo firewall-cmd --zone=public --permanent --add-port=8082/udp
sudo firewall-cmd --zone=public --permanent --add-port=443/tcp
sudo firewall-cmd --zone=public --permanent --add-port=80/tcp
sudo firewall-cmd --reload

