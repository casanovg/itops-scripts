#!/bin/sh

# Install Zabbix Agent on Fedora
# .......................................
# 2019-10-29  gustavo.casanova@gmail.com

ZABBIX_SERVER_IP_ADDR=10.6.17.61
ZABBIX_SERVER_IP_MASK=32
AGENT_PORT=10050
AGENT_PROTOCOL=tcp

echo
echo "Installing Zabbix agent ..."
echo
sudo dnf install -y zabbix-agent

echo
echo "Copying HTA customized agent configuration file to the agent folder ..."
sudo cp ~/itops-scripts/utils/zabbix_agentd.conf /etc/zabbix/zabbix_agentd.conf

echo
echo "Creating firewall zone and enabling agent port (Server: $ZABBIX_SERVER_IP_ADDR)"
echo
sudo firewall-cmd --new-zone=zabbix --permanent
sudo firewall-cmd --permanent --zone=zabbix --add-source=$ZABBIX_SERVER_IP_ADDR/$ZABBIX_SERVER_IP_MASK
sudo firewall-cmd --permanent --zone=zabbix --add-port=$AGENT_PORT/$AGENT_PROTOCOL
sudo firewall-cmd --reload

echo
echo "Enabling and starting Zabbix agent service ..."
echo
sudo systemctl enable zabbix-agent.service
sudo systemctl start zabbix-agent.service

echo
echo "Zabbix agent setup complete!"
echo

