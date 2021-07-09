#!/bin/bash
#sudo su - stack

if [ -f $HOME/openstack-info ];
then 
    source  $HOME/openstack-info
    sudo subscription-manager register --username=${RHEL_USER} --password=${RHEL_PASSWORD}
    echo "Using openshift-info to register system: "  
    sudo subscription-manager attach --pool="$POOL_ID"
else
    sudo subscription-manager register
    echo "ENTER POOL ID: "  
    read POOL_ID 
    sudo subscription-manager attach --pool="$POOL_ID"

fi

sudo subscription-manager release --set=8.2