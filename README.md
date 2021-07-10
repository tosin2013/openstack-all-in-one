# OpenStack 16.1 all in one
This repo will install OpenStack 16.1 All-In-One on a single node. This repo will also explain how to install OpenShift on top of the Openstack deployment.
![main-page](https://user-images.githubusercontent.com/1975599/125079864-16f60100-e092-11eb-86b0-45808d1f9cfc.png)


## Requirements
* RHEL 8.2
    * [RED HAT ENTERPRISE LINUX
    8.2](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/8.2_release_notes/index)
    * [Download](https://access.redhat.com/downloads/content/479/ver=/rhel---8/8.2/x86_64/product-software)

* Two ethernet Ports
    * First interface used for general connectivity.
    * Second interface used for the OpenStack services. This secondary interface needs to be connected to a separate router. 
        * gl-inet is an example router 
        * a small 5 port router is another alternative.
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
./openstack-all-in-one/create-source.sh secondary_network_interface
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
https://youripaddress
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
$ openstack endpoint list 
+----------------------------------+-----------+--------------+--------------+---------+-----------+------------------------------------------------+
| ID                               | Region    | Service Name | Service Type | Enabled | Interface | URL                                            |
+----------------------------------+-----------+--------------+--------------+---------+-----------+------------------------------------------------+
| 071fc06d671a4bf192a3bad0db02ffed | regionOne | nova         | compute      | True    | public    | http://192.168.1.25:8774/v2.1                  |
| 08769e8644ff472990bf1bc12398e5a1 | regionOne | swift        | object-store | True    | admin     | http://192.168.1.25:8080                       |
| 143143b0145f42cbb8aa5ece132b19a2 | regionOne | neutron      | network      | True    | internal  | http://192.168.1.25:9696                       |
| 14921eee2ca84f6ca0e19578bb4a8dbc | regionOne | nova         | compute      | True    | internal  | http://192.168.1.25:8774/v2.1                  |
| 2974b712c4dc4a199700b9e171d9a4b2 | regionOne | placement    | placement    | True    | public    | http://192.168.1.25:8778/placement             |
| 2ab138cbe8ea45db8279e46b21ef2903 | regionOne | placement    | placement    | True    | admin     | http://192.168.1.25:8778/placement             |
| 2bfa0bd6f14340bbbaca6828666207d9 | regionOne | cinderv3     | volumev3     | True    | public    | http://192.168.1.25:8776/v3/%(tenant_id)s      |
| 340e7a5c4583404e8861f3e0c49b2978 | regionOne | glance       | image        | True    | public    | http://192.168.1.25:9292                       |
| 359370bb4c7d403daafa45b39e230c0e | regionOne | cinderv2     | volumev2     | True    | internal  | http://192.168.1.25:8776/v2/%(tenant_id)s      |
| 42f81ae2003543768be7154bb3901463 | regionOne | swift        | object-store | True    | internal  | http://192.168.1.25:8080/v1/AUTH_%(tenant_id)s |
| 45d38756abef4e0da5f2e8fc99fd97f4 | regionOne | keystone     | identity     | True    | admin     | http://192.168.1.25:35357                      |
| 58d58e609ac54e1c81327344fcdc1f99 | regionOne | cinderv3     | volumev3     | True    | admin     | http://192.168.1.25:8776/v3/%(tenant_id)s      |
| 64de4135c8604808954b5fc25c88dd77 | regionOne | placement    | placement    | True    | internal  | http://192.168.1.25:8778/placement             |
| 70c6f629f9fe4832aa9324f9ecfd7b9e | regionOne | glance       | image        | True    | admin     | http://192.168.1.25:9292                       |
| 87bc8cdd57334a159cceb2da79c1b9d8 | regionOne | keystone     | identity     | True    | public    | http://192.168.1.25:5000                       |
| 8aeae5cb55c6441eb0f0c77787dcf408 | regionOne | cinderv2     | volumev2     | True    | admin     | http://192.168.1.25:8776/v2/%(tenant_id)s      |
| 9aa54f77221b4fd080b02dcf5ad6e808 | regionOne | neutron      | network      | True    | admin     | http://192.168.1.25:9696                       |
| ab27ac29110241d8b48dbb1222d9bf57 | regionOne | neutron      | network      | True    | public    | http://192.168.1.25:9696                       |
| c16dc5ba55de4de9a74a85211bc025a0 | regionOne | keystone     | identity     | True    | internal  | http://192.168.1.25:5000                       |
| c9165502edce4faa9c8a1006908260db | regionOne | cinderv2     | volumev2     | True    | public    | http://192.168.1.25:8776/v2/%(tenant_id)s      |
| ce1056f7bdef46f4b03428f51507505c | regionOne | swift        | object-store | True    | public    | http://192.168.1.25:8080/v1/AUTH_%(tenant_id)s |
| d7d066120ea34f2ca286320756d911a8 | regionOne | nova         | compute      | True    | admin     | http://192.168.1.25:8774/v2.1                  |
| ddf95ef88f524230affd6efc7dad508c | regionOne | cinderv3     | volumev3     | True    | internal  | http://192.168.1.25:8776/v3/%(tenant_id)s      |
| e9af20c2bc9a4e66abe1c51cef359830 | regionOne | glance       | image        | True    | internal  | http://192.168.1.25:9292                       |
+----------------------------------+-----------+--------------+--------------+---------+-----------+------------------------------------------------+

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
