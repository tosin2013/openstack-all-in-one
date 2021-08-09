#!/bin/bash 
# https://docs.openstack.org/project-install-guide/dns/draft/create-zone.html

if [ -z $1 ];
then 
  echo "Please pass domain name."
  echo "USAGE: $0 example.com"
  exit 1
fi 

DOMAIN_NAME=${1}

export OS_CLOUD=standalone
openstack zone create --email dnsmaster@${DOMAIN_NAME} ${DOMAIN_NAME}. || exit $?
openstack zone list

echo "Run 'export OS_CLOUD=standalone && openstack zone list' to check status"