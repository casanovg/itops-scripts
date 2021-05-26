#!/bin/sh

#
# Install Zabbix Agent on Fedora
# ===============================
# 2019-10-29 Gustavo Casanova
#

ZABBIX_SERVER_IP_ADDR=10.6.17.61
ZABBIX_SERVER_IP_MASK=32
AGENT_PORT=10050
AGENT_PROTOCOL=tcp

# Install Zabbix agento for Fedora
sudo dnf install zabbix-agent

# Copy customized agent configuration file to the agent folder
sudo cp ~/itops-scripts/utils/zabbix_agentd.conf /etc/zabbix/zabbix_agentd.conf

# Create firewall zone and enable agent port 
sudo firewall-cmd --new-zone=zabbix --permanent
sudo firewall-cmd --permanent --zone=zabbix --add-source=$ZABBIX_SERVER_IP_ADDR/$ZABBIX_SERVER_IP_MASK
sudo firewall-cmd --permanent --zone=zabbix --add-port=$AGENT_PORT/$AGENT_PROTOCOL
sudo firewall-cmd --reload

# Enable ans start Zabbix agent service
sudo systemctl enable zabbix-agent.service
sudo systemctl start zabbix-agent.service

