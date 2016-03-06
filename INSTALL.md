# 0: Zero
## Desc
* / only
* extremally thin (w/o selinux NM; 833M, 231 rpms)
* += dnf mc rpmreaper net-tools
* net: 192.168.0.1, server.lan
* updated to 2016-03-02
## TODO
* yum -y install epel-release
* yum install dnf mc rpmreaper net-tools
* dnf update
* /etc/sysconfig/selinux: disabled; /etc/fstab: /dev/vda
* yum clean all; dnf clean all; dd if=/dev/zero of=/bigfile bs=1M; rm -f /bigfile

# 1: LDAP
## Desc:
Nothing
### Non-LDAP
* Caches: ln -s /var/cahce/{dnf,yum}
* NTP (chrony): dnf install chrony; systemctl enable chronyd.service; systemctl start chronyd.service
* NFS (nfs-utils?)
* ?diskless
* ?cups
* ?sane

### LDAP
* LDAP:
(dc=lan)
 * instal packages:
```
dnf install 389-ds-base
? 389-console 389-admin 389-adminutil
```
 * create user&group:
```
groupadd -g 55 ldap
useradd -c LDAP -d /var/lib/dirsrv -g 55 -s /sbin/nologin -u 55 ldap
passwd ldap
```
 * config ldap server:
```
setup-ds.pl:
 yes
 custom
 user: ldap;
 group: ldap;
 port: 389
 DM DN: cn=odmin:tratatata
```
 * Go:
```
systemctl enable dirsrv.target
systemctl start dirsrv.target
systemctl status dirsrv.target
```
* PAM:
 * create LDAP entries:
```
ldapadd -x -D "cn=odmin" -w tratatata -h localhost -p 389 -f Users.ldif
```
 * install packages:
```
dnf install nss-pam-ldapd authconfig
```
 * configure pam:
 * create homes:
 * go:
* DNS
* DHCP
* SAMBA
* IMAP/POP3
* SMTP
* Proxy
* FTP (pureftpd)
* HTTP
* WebDAV
* XMPP
### 386

### Addons
* CUPS
* SANE
* DiskLess
* eGW etc

# 2: upgrade
* ...
