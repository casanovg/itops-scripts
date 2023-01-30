#!/bin/sh

# Enable huge pages
# ...........................
# 2022-02-22 Worker's union

#!/bin/bash -e

# https://xmrig.com/docs/miner/hugepages#onegb-huge-pages

sudo sysctl -w vm.nr_hugepages=1280

sudo bash -c "echo vm.nr_hugepages=1280 >> /etc/sysctl.conf"

echo "Huge pages successfully enabled"

