# Install OpenShift on OpenStack All-in-one
This guide will show how to install OpenShift on your deployed Openstack All-in-one box.

```
$ oc get nodes
NAME                             STATUS   ROLES    AGE     VERSION
openstack-6jdm8-master-0         Ready    master   7h30m   v1.20.0+87cc9a4
openstack-6jdm8-master-1         Ready    master   7h30m   v1.20.0+87cc9a4
openstack-6jdm8-master-2         Ready    master   7h29m   v1.20.0+87cc9a4
openstack-6jdm8-worker-0-242hn   Ready    worker   6h58m   v1.20.0+87cc9a4
openstack-6jdm8-worker-0-7rhjm   Ready    worker   6h58m   v1.20.0+87cc9a4

```

Bastion Configuration
---
**Download oc cli and openshift-installer**
```
curl -OL https://raw.githubusercontent.com/tosin2013/openshift-4-deployment-notes/master/pre-steps/configure-openshift-packages.sh
chmod +x configure-openshift-packages.sh
./configure-openshift-packages.sh -i
```

**Generate sshkey to access nodes**
```
ssh-keygen -t rsa -b 4096 -f ~/.ssh/cluster-key -N ''

chmod 400 ~/.ssh/cluster-key.pub
cat  ~/.ssh/cluster-key.pub

eval "$(ssh-agent -s)"
ssh-add ~/.ssh/cluster-key 
```

Openstack Configuration
---

**Increase cluster Quota for project**
* `Click Admin`
* `System->Defaults`
  * `Compute Quotas->Update Defaults`
    *![compute-quota](https://user-images.githubusercontent.com/1975599/125079750-fa59c900-e091-11eb-925f-59649d797125.png)
  * `Volume Quotas->Update Defaults`
    * ![volume-quota](https://user-images.githubusercontent.com/1975599/125079790-03e33100-e092-11eb-90de-6c6e46017a34.png)
  
`You can also disable quota using the commands below`
```
$ export OS_CLOUD=standalone

$ openstack quota set --secgroups -1 --secgroup-rules -1 --cores -1 --ram -1 --gigabytes -1 admin

$ openstack quota show admin
```

**Create OpenShift cluster flavor**
```
cd openstack-all-in-one/
./openstack-commands/openstack-flavors.sh
```

**Add swiftoperator permissions to project**
```
export OS_CLOUD=standalone
openstack role add --user <user> --project <project> swiftoperator
```

**Configure external network**  
[OpenStack All-in-One Deployment notes](README.md)
* **Variables for public and private network**
* **Create public netowork**
* **Create router and set gateway**. 

*The script below will configure your network for Openshift deployment.*
```
./openstack-commands/create-network-for-openshift.sh
```

**Check network endpoints**
```
export OS_CLOUD=standalone
openstack network list --long -c ID -c Name -c "Router Type"
```

**if you are using designate you can create the BASE_DOMAIN**
```
export BASE_DOMAIN=example.com
export CLUSTER_NAME=openstack
./openstack-commands/configure_dns_zone.sh ${CLUSTER_NAME}.${BASE_DOMAIN}
```

**Create floating ip for ingress and api routes**
```
export OS_CLOUD=standalone
export CLUSTER_NAME=openstack
export BASE_DOMAIN=example.com
export EXTERNAL_NETWORK=public
openstack floating ip create --description "API ${CLUSTER_NAME}.${BASE_DOMAIN}" ${EXTERNAL_NETWORK}
openstack floating ip create --description "Ingress  ${CLUSTER_NAME}.${BASE_DOMAIN}"  ${EXTERNAL_NETWORK}
```

**if you are using designate you can create the A records for the folating ips**
```
openstack recordset create --record 'ipaddress' --type A ${CLUSTER_NAME}.${BASE_DOMAIN}. api
openstack recordset create --record 'ipaddress' --type A ${CLUSTER_NAME}.${BASE_DOMAIN}. *.apps
```

**add ips to dns server**
```
api.<cluster_name>.<base_domain>.  IN  A  <API_FIP>
*.apps.<cluster_name>.<base_domain>. IN  A <apps_FIP>
```

Deploy OpenShift
---

**download pull secret**
* https://cloud.redhat.com/openshift/install/openstack/installer-provisioned

**Generate install-config and edit any nesessary settings**
```
$ openshift-install create install-config --dir $HOME/cluster
? SSH Public Key /home/stack/.ssh/cluster-key.pub
? Platform openstack
? Cloud standalone
? ExternalNetwork public
? APIFloatingIPAddress 192.168.1.10
? FlavorName openshift.image
? Base Domain example.com
? Cluster Name openstack
? Pull Secret [? for help] 
INFO Install-Config created in: /home/stack/cluster 
```

**edit and backup install-config.yaml if necessary**
```
vim ~/cluster/install-config.yaml 
cp ~/cluster/install-config.yaml  $HOME/install-config.yaml 
```

**Start OpenShift Install**
```
openshift-install create cluster --dir $HOME/cluster --log-level debug
```

Post Step
---
### Configuring application access with floating IP addresses

**Get port info**
```
openstack port list
openstack port show <cluster_name>-<cluster_ID>-ingress-port
```


**Attach the port to the IP address**
```
$ openstack floating ip list
$ PORTNAME="<cluster_name>-<cluster_ID>-ingress-port"
$ PORT_ID=$(openstack port list | grep ${PORTNAME} | awk '{print $2}')
$ openstack floating ip set --port ${PORT_ID} <apps_FIP>
```