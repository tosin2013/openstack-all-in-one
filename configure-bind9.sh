#!/bin/bash 
SUDO=''
if (( $EUID != 0 )); then
    SUDO='sudo'
fi

source  $HOME/network_info

${SUDO} yum install bind bind-utils -y
if [ ! -f /etc/named.conf.orig ];
then
    ${SUDO} cp /etc/named.conf /etc/named.conf.orig
else 
    ${SUDO} cp /etc/named.conf.orig /etc/named.conf
fi 
${SUDO} sed -i -e "s/listen-on port.*/listen-on port 53 { 127.0.0.1; ${IP}; };/" /etc/named.conf

${SUDO} rndc-confgen -a

if ! ${SUDO} grep -q rndc.key "/etc/named.conf"; then
  ${SUDO} sed -i '/^options.*/i \
    include "/etc/rndc.key"; \
    controls { \
            inet 127.0.0.1 allow { localhost; } keys { "rndc-key"; }; \
    };' /etc/named.conf
fi


${SUDO} sed -i '/allow-query.*/d' /etc/named.conf
${SUDO} sed -i '/recursion.*/d' /etc/named.conf

${SUDO} sed -i '/^options.*/a \
        allow-new-zones yes; \
        allow-query { any; }; \
        recursion no;' /etc/named.conf

if ! ${SUDO} grep -q forwarders "/etc/named.conf"; then
${SUDO} sed -i ' /recursing-file.*/a   \
        forwarders { \
            '${DNS_SERVER1}'; \
            '${DNS_SERVER2}'; \
        };' /etc/named.conf
fi

${SUDO} tee   /etc/rndc.conf <<EOT
include "/etc/rndc.key";
options {
        default-key "rndc-key";
        default-server 127.0.0.1;
        default-port 953;
};
EOT

${SUDO} named-checkconf /etc/named.conf

${SUDO} firewall-cmd --permanent --add-port=53/udp
${SUDO} firewall-cmd --permanent --add-port=953/udp
${SUDO} firewall-cmd --reload
${SUDO} firewall-cmd --list-all

${SUDO} setsebool -P named_write_master_zones on
${SUDO} chmod g+w /var/named
${SUDO} chown named:named /etc/rndc.conf
${SUDO} chown named:named /etc/rndc.key
${SUDO} chmod 600 /etc/rndc.key

${SUDO} systemctl enable named
${SUDO} systemctl start named
${SUDO} systemctl status named

${SUDO} dig @localhost localhost
${SUDO} rndc status

sed -i 's/export DNS_SERVER1=.*/export DNS_SERVER1='$IP'/g' $HOME/network_info
${SUDO}  tee /etc/resolv.conf.manually-configured  > /dev/null <<EOT
nameserver ${DNS_SERVER1}
nameserver ${DNS_SERVER2}
EOT

${SUDO} rm -rf /etc/resolv.conf
${SUDO} ln -s /etc/resolv.conf.manually-configured /etc/resolv.conf