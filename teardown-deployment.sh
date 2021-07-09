#!/bin/bash 

echo "Tearing down OpenStack environment"
if type pcs &> /dev/null; then
    sudo pcs cluster destroy
fi
if type podman &> /dev/null; then
    echo "Removing podman containers and images (takes times...)"
    COUNT=$(podman ps -a | wc -l)
    while [ ${COUNT} -gt 1 ]
    do
        sudo podman rm -af
        sudo podman rmi -af
        echo "Trying Again in  5 minutes"
        sleep 360s
        COUNT=$(podman ps -a | wc -l)
    done
fi

sudo rm -rf \
    /var/lib/tripleo-config \
    /var/lib/config-data /var/lib/container-config-scripts \
    /var/lib/container-puppet \
    /var/lib/heat-config \
    /var/lib/image-serve \
    /var/lib/containers \
    /etc/systemd/system/tripleo* \
    /var/lib/mysql/*
sudo systemctl daemon-reload
