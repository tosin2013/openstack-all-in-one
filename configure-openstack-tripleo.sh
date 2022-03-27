#!/bin/bash 
set -xe

function drivecheck(){
  if [ ! -f  $HOME/skipdirves ];
  then
    echo "sda" >   $HOME/skipdirves
  fi 

  SKIPDRIVES=$(cat $HOME/skipdirves  | tr '\n' ' '  | xargs | sed 's/ /\\|/g')
  CHECK_DRIVE_COUNT=$(ls /dev/*sd* | grep -v ''${SKIPDRIVES}'' | wc -l)
  echo ${CHECK_DRIVE_COUNT}
  if [ "$CHECK_DRIVE_COUNT" -gt 1 ];
  then 
    echo "more than one drive found"
    export DRIVES=$(ls /dev/sd* | grep -v  ''${SKIPDRIVES}''  |  xargs)
  elif [ "$CHECK_DRIVE_COUNT" -eq 0 ];
  then 
      echo "checking for nvme drives"
      export DRIVES="$(ls /dev/nvme0* | grep /dev/nvme0n1)"
  elif [ "$CHECK_DRIVE_COUNT" -eq 1 ];
  then
       echo "one drive found"
       export DRIVES="$(ls /dev/sd* | grep -v sda)"
  fi 
}

CHECKLOGGINGUSER=$(whoami)
if [ ${CHECKLOGGINGUSER} != "stack" ];
then 
  echo "login as stack user to run script."
  echo "You are currently logged in as $USER"
  exit 1
fi

if [ ! -f $HOME/network_info ];
then 
  echo "$HOME/network_info not found ."
  echo "Plese run the create-source.sh"
  exit 1
fi 

openstack tripleo container image prepare default --output-env-file "$HOME"/containers-prepare-parameters.yaml
sudo tee -a $HOME/containers-prepare-parameters.yaml << EOF 
  ContainerImageRegistryCredentials:
    registry.redhat.io:
      rhn_user: 'rhn_password'
EOF

if [ -f $HOME/openstack-info ];
then 
  source  $HOME/openstack-info
  export USERNAME=${RHEL_USER}
  export PASSWORD=${RHEL_PASSWORD}
else
  read -p "Enter your username: " USERNAME
  read -sp "Enter your password: " PASSWORD
fi



sed -i 's/rhn_user/'${USERNAME}'/' $HOME/containers-prepare-parameters.yaml
sed -i 's/rhn_password/'${PASSWORD}'/' $HOME/containers-prepare-parameters.yaml


source  $HOME/network_info
drivecheck

cat <<EOF > $HOME/ceph_parameters.yaml
parameter_defaults:
  CephAnsibleDisksConfig:
    osd_scenario: lvm
    osd_objectstore: bluestore
    devices:
EOF
arr=( ${DRIVES} )
for i in "${arr[@]}"; do echo "      - ${i}" >>$HOME/ceph_parameters.yaml ; done
echo "  CephAnsibleExtraConfig:
    cluster_network: ${IP_OCTET}.0/24
    public_network:  ${IP_OCTET}.0/24
  CephPoolDefaultPgNum: 8
  CephPoolDefaultSize: 1
" | sudo tee -a  $HOME/ceph_parameters.yaml


cat <<EOF > $HOME/standalone_parameters.yaml
parameter_defaults:
  CloudName: $IP
  # default gateway
  ControlPlaneStaticRoutes: []
  Debug: true
  DeploymentUser: $USER
  DnsServers:
    - $DNS_SERVER1
    - $DNS_SERVER2
  DockerInsecureRegistryAddress:
    - $IP:8787
  NeutronPublicInterface: $INTERFACE
  # domain name used by the host
  CloudDomain: localdomain
  NeutronDnsDomain: localdomain
  # re-use ctlplane bridge for public net, defined in the standalone
  # net config (do not change unless you know what you're doing)
  NeutronBridgeMappings: datacentre:br-ctlplane
  NeutronPhysicalBridge: br-ctlplane
  # enable to force metadata for public net
  #NeutronEnableForceMetadata: true
  StandaloneEnableRoutedNetworks: false
  StandaloneHomeDir: $HOME
  InterfaceLocalMtu: 1500
  NtpServer: $NTP_SERVER1
EOF

if [ $USE_DESIGNATE  == "true"  ];
then 
  sudo cp  /usr/share/openstack-tripleo-heat-templates/environments/designate-config.yaml ${HOME}/designate-config.yaml
  sed -i 's/10.0.0.51/'$IP'/g' ${HOME}/designate-config.yaml
  sed -i 's/172.17.0.251/127.0.0.1/g' ${HOME}/designate-config.yaml
fi 