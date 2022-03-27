# OpenStack 16.2 all in one
This repo will install OpenStack 16.1 All-In-One on a single node. This repo will also explain how to install OpenShift on top of the Openstack deployment.![OpenShift on OpenStack](https://user-images.githubusercontent.com/1975599/125313449-3ba4df80-e303-11eb-8256-37a89821a521.png)

![main-page](https://user-images.githubusercontent.com/1975599/125079864-16f60100-e092-11eb-86b0-45808d1f9cfc.png)


## Requirements
* RHEL 8.4
    * [RED HAT ENTERPRISE LINUX
    8.4](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/8.4_release_notes/index)
    * [Download](https://access.redhat.com/downloads/content/479/ver=/rhel---8/8.4/x86_64/product-software)

* Two ethernet Ports configured with static networks
    * First interface used for general connectivity.
    * Second interface used for the OpenStack services. This secondary interface needs to be connected to a separate router. 
        * gl-inet is an example router 
        * a small 5 port router is another alternative.
        * The secondary router must also have access to the internet. 
* Your system must have at least 4 CPUs, 8GB RAM, and 30GB disk space.
* Your system must have at least 8 CPUs, 128GB RAM, and 1TB of external disk space for an OpenShift install.
* Minimum of two external disks for Ceph
* DNS server for OpenShift installation

## Confiure host for OpenStack
* Install RHEL 8.2 with `Server with GUI` this is optional if you want to access the cluster UI on the host.
* Configure first and second interface with static ips
* set hostname as FQDN example `openstack.example.com`

**ssh into node**
```
ssh-copy-id root@ipaddress
ssh root@ipaddress
```

**add stack user**
```
curl -OL https://raw.githubusercontent.com/tosin2013/openstack-all-in-one/main/setup-stack.sh
chmod +x setup-stack.sh
./setup-stack.sh
exit
```
 
## System Configration   
**Switch to stack user**
```
ssh-copy-id stack@ipaddress
ssh stack@ipaddress
sudo su - stack 
```

**Optional: create openstack-info for scripts**
```
cat >$HOME/openstack-info<<EOF
export RHEL_USER=username@redhat.com
export RHEL_PASSWORD="Y0uRp@$$woRd"
export POOL_ID=000000000000000000000
export TIME_SERVER=0.rhel.pool.ntp.org
export PRIMARY_DNS_SERVER=192.168.1.2
export SECONDARY_DNS_SERVER=1.1.1.1
export SECONDARY_INTERFACE_NAME=eno2
export USE_DESIGNATE=Y
EOF
```

## Run the following if git is already installed
**Clone OpenStack repo**
```
git clone https://github.com/tosin2013/openstack-all-in-one.git
```

**Register system**
```
./openstack-all-in-one/register-system.sh
```

**Configure OpenStack packages**
```
./openstack-all-in-one/configure-openstack-subs.sh
```

**Congiure TMUX**
```
./openstack-all-in-one/configure-tmux.sh
```

## If git is not installed run the following

```
curl -OL https://raw.githubusercontent.com/tosin2013/openstack-all-in-one/main/system-setup.sh
chmod +x system-setup.sh
./system-setup.sh
```

**Clone OpenStack repo**
```
git clone https://github.com/tosin2013/openstack-all-in-one.git
```

## Configure settings for deployment

**Configure Network**
```
./openstack-all-in-one/create-source.sh  
```

**Configure Bind9 if using designate** 
```
./openstack-all-in-one/configure-bind9.sh
```

**Optional: Skip drives to be used with Ceph**
> If you would like to skip drives that would be used with ceph create the file below
```
$ cat >$HOME/skipdirves<<EOF
sda
sdb
EOF
```

**Configure TripleO Parameters** 
```
./openstack-all-in-one/configure-openstack-tripleo.sh
```

## Deploy Openstack
```
$ tmux new-session -t openstack-install
$ ./openstack-all-in-one/deploy-tripleo.sh
```

**Access Openstack console**
```
http://youripaddress
```

**Get login info**
```
$ ./openstack-all-in-one/openstack-commands/get-credentials.sh

or 

$ cat $HOME/standalone-passwords.conf | grep undercloud_admin_password
undercloud_admin_password: LoginPAssword
```

**View Openstack Endpoints**
```
$ export OS_CLOUD=standalone     
$ openstack endpoint list 
+----------------------------------+-----------+--------------+--------------+---------+-----------+---------------------------------------------+
| ID                               | Region    | Service Name | Service Type | Enabled | Interface | URL                                         |
+----------------------------------+-----------+--------------+--------------+---------+-----------+---------------------------------------------+
| 1a37371d8162489aa9663f307244d693 | regionOne | cinderv3     | volumev3     | True    | internal  | http://192.168.1.20:8776/v3/%(tenant_id)s      |
| 1ba6cba14ac84e1bab7bf99d3f3253ee | regionOne | glance       | image        | True    | admin     | http://192.168.1.20:9292                       |
| 1bc0591585c74a5ba4c236de2fb8f42b | regionOne | keystone     | identity     | True    | public    | http://192.168.1.20:5000                       |
| 1e350bb4bdde4b87b58e9906543899c7 | regionOne | swift        | object-store | True    | public    | http://192.168.1.20:8080/v1/AUTH_%(tenant_id)s |
| 23a8bb1eff2f475cb707bdaba2604ca5 | regionOne | cinderv2     | volumev2     | True    | admin     | http://192.168.1.20:8776/v2/%(tenant_id)s      |
| 269a7113e334450e9618481affff7b5d | regionOne | keystone     | identity     | True    | internal  | http://192.168.1.20:5000                       |
| 315eee54bf6e41898e0efbb9ade81e2a | regionOne | cinderv2     | volumev2     | True    | internal  | http://192.168.1.20:8776/v2/%(tenant_id)s      |
| 5ae5a368350044c4832c9ba74166da2a | regionOne | placement    | placement    | True    | public    | http://192.168.1.20:8778/placement             |
| 5be24ab1851745c086162a59c4068615 | regionOne | cinderv2     | volumev2     | True    | public    | http://192.168.1.20:8776/v2/%(tenant_id)s      |
| 60ae5e5904614b2e9818e99967907d26 | regionOne | nova         | compute      | True    | public    | http://192.168.1.20:8774/v2.1                  |
| 6e430f0218ed4ef3a44465c70187ffbe | regionOne | cinderv3     | volumev3     | True    | public    | http://192.168.1.20:8776/v3/%(tenant_id)s      |
| 7152512d8e534837a09cc3745fad8bbf | regionOne | designate    | dns          | True    | internal  | http://192.168.1.20:9001                       |
| 7a282b48c1c54550b016cc1aa0ac1662 | regionOne | glance       | image        | True    | public    | http://192.168.1.20:9292                       |
| 91978fb8860c4732b0829dca8695d669 | regionOne | nova         | compute      | True    | admin     | http://192.168.1.20:8774/v2.1                  |
| 93f3e8f9c1364d3f8a9d9e626257d9f0 | regionOne | neutron      | network      | True    | admin     | http://192.168.1.20:9696                       |
| 9587aba1f84a4882b4650866420b618d | regionOne | neutron      | network      | True    | public    | http://192.168.1.20:9696                       |
| 959a3210294e4413af23d709276df0b3 | regionOne | designate    | dns          | True    | admin     | http://192.168.1.20:9001                       |
| ae883c5511b54750b5364d62648749de | regionOne | glance       | image        | True    | internal  | http://192.168.1.20:9292                       |
| af9945acc0644a3caca6b9b0a1afd4d7 | regionOne | keystone     | identity     | True    | admin     | http://192.168.1.20:35357                      |
| b646c5fe9cfa4791b50688f6292aeef0 | regionOne | placement    | placement    | True    | admin     | http://192.168.1.20:8778/placement             |
| bf205b8aded947d78c47087656dc599c | regionOne | neutron      | network      | True    | internal  | http://192.168.1.20:9696                       |
| d21b5ba094384d19b11d3f7216b8ad4e | regionOne | designate    | dns          | True    | public    | http://192.168.1.20:9001                       |
| d86e9f4607224b19bf3aebf18d531d21 | regionOne | cinderv3     | volumev3     | True    | admin     | http://192.168.1.20:8776/v3/%(tenant_id)s      |
| da4cc7483bec4ddfaefbaf6342229f54 | regionOne | nova         | compute      | True    | internal  | http://192.168.1.20:8774/v2.1                  |
| dd00effe7fa54e0085b9b091d7ab73d1 | regionOne | swift        | object-store | True    | internal  | http://192.168.1.20:8080/v1/AUTH_%(tenant_id)s |
| fa0d25c6197e4f41a3f8d88f6f95d673 | regionOne | placement    | placement    | True    | internal  | http://192.168.1.20:8778/placement             |
| ff192c431c5a4c21a66c88269a98c462 | regionOne | swift        | object-store | True    | admin     | http://192.168.1.20:8080                       |
+----------------------------------+-----------+--------------+--------------+---------+-----------+---------------------------------------------+

```

**If you are using designate patch the rndc**
```
./openstack-all-in-one/patch_rndckey.sh
```

## OpenStack All-in-One Deployment Tips
[OpenStack All-in-One Deployment Tips](openstack-commands/README.md)

## Install OpenShift using IPI
[Install OpenShift](openstack-commands/configure-openshift.md)


# Cleanup Instructions 
Tear down deployment. 
```
./openstack-all-in-one/teardown-deployment.sh  && ./openstack-all-in-one/cleanup-ceph.sh 
```

## Links
https://access.redhat.com/documentation/en-us/red_hat_openstack_platform/16.1/html/standalone_deployment_guide/index

https://docs.openstack.org/project-deploy-guide/tripleo-docs/latest/deployment/standalone.html

https://egallen.com/openstack-16.1/

https://hackmd.io/@rh-openstack-ci/rki7LxDP8

https://gitlab.cee.redhat.com/whayutin/ansible-kvm-vmss

https://www.redhat.com/sysadmin/tripleo-standalone-system
