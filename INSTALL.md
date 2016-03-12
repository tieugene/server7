# 0: Zero

## Desc:
* / only
* extremally thin (w/o selinux NM; 833M, 231 rpms)
* += dnf mc rpmreaper net-tools chrony man-db wget telnet git patch bind-utils
* net: 192.168.0.1, server.lan
* updated to 2016-03-02

## TODO:
* yum -y install epel-release
* yum install dnf mc rpmreaper net-tools chrony man-db wget telnet git patch
* dnf update
* chronyd:
```systemctl enable chronyd && systemctl start chronyd```
* /etc/sysconfig/selinux: disabled;
* /etc/fstab: /dev/vda
* rpmreaper
* clean:
```
yum clean all
dnf clean all
dd if=/dev/zero of=/bigfile bs=1M; rm -f /bigfile
```

# 1: LDAP

## Desc:
Pure LDAP

## TODO:
* fstab:
* caches:
```
mkdir /mnt/shares/cache
mv /var/cache/{dnf,yum}
ln -s /var/cahce/{dnf,yum}
```
* packages:
```
dnf install\
 openldap-servers\
 openldap-clients\
 nss-pam-ldapd\
 authconfig\
 bind-sdb\
 dhcp\
 smbldap-tools\
 samba\
 dovecot\
 postfix
```
* Prepare:
([HOWTO](http://www.server-world.info/en/note?os=CentOS_7&p=openldap))
```
cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG
chown ldap. /var/lib/ldap/DB_CONFIG
systemctl enable slapd && systemctl start slapd && systemctl status slapd
sh/init_ldap.sh
```
* Root:
```
sh/ldap_add.sh ldif/0-Root.ldif
```

# 2. PAM
* packages: authconfig nss-pam-ldap
* create LDAP entries:
```
sh/ldap_add.sh ldif/1-Users.ldif
sh/mk_users.sh
```
* configure pam:
```
authconfig\
 --enableldap\
 --enableldapauth\
 --disablenis\
 --enablecache\
 --ldapserver=localhost\
 --ldapbasedn=dc=lan\
 --updateall
```
* configure ldap client:
```
patch /etc/openldap/ldap.conf diff/etc/openldap/ldap.conf.diff
```
* enable services:
```
systemctl enable nscd && systemctl start nscd && systemctl status nscd
systemctl enable nslcd && systemctl start nslcd && systemctl status nslcd
```
* Activate changes:
```
init 6
```
* Create homes:
```
mkdir -p /mnt/shares/home
for i in `getent passwd | gawk -F'[/:]' '{print $1}' | grep ^user`; do mkdir /mnt/shares/home/$i; chown $i:users /mnt/shares/home/$i; done
```
# 3. DNS
* packages: bind-sdb bind-utils
* [convert schema](http://technik.blogs.nde.ag/2012/08/19/converting-and-adding-openldap-schema-files/):
```
sh/schema2ldif_dnszone.sh
```
* add schema:
```
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/dnszone.ldif
```
* add records:
```
sh/ldap_add.sh ldif/2-DNS.ldif
sh/mk_hosts.sh
```
* configure named:
```
patch /etc/named.conf diff/etc/named.conf.diff
patch /etc/sysconfig/named diff/etc/sysconfig/named.diff
patch /etc/resolv.conf diff/etc/resolv.conf.diff
```
* service:
```
systemctl enable named-sdb && systemctl start named-sdb && systemctl status named-sdb
```
* check:
```
host host002
host 192.168.0.2
host ya.ru
```
* TODO:
 * hostXXX.lan not resolved
 * indices

# 4. DHCP
* packages: dhcp
* convert schema:
```
sh/schema2ldif.sh /etc/openldap/schema/dhcp.schema
mv dhcp.ldif /etc/openldap/schema/
```
* add schema:
```
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/dhcp.ldif
```
* add LDAP entries:
```
sh/ldap_add.sh ldif/3-DHCP.ldif
sh/mk_dhcp.sh
```
* configure:
```
patch /etc/dhcp/dhcpd.conf diff/etc/dhcp/dhcpd.conf.diff
```
* start service:
```
systemctl enable dhcpd && systemctl start dhcpd && systemctl status dhcpd
```
* check

# 5. SAMBA
* packages: samba smbldap-tools
* convert schema:
```
sh/schema2ldif.sh /etc/openldap/schema/samba.schema
mv ~/samba.ldif /etc/openldap/schema/
```
* add schema:
```
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/samba.ldif
```
* get domain SID:
```
SID=`net getlocalsid | gawk '{print $6}'`
```
* configure:
```
# patch /etc/smbldap-tools/smbldap-bind.conf
# patch /etc/smbldap-tools/smbldap.conf
# patch /etc/smb.conf
```
* it's alike a magic:
```
smbldap-populate (pass: root pass)
```
* services:
```
```
* check
* TODO:
 * indices

# 6. IMAP/POP3
# 7. SMTP
# 8. FTP (pureftpd)
# 9. HTTP
# 10. WebDAV

# Non-LDAP:
* Proxy
* NFS
* logrotate (compress)
* logwatch
* mailrc
* fetchmail

# Addons
* CUPS
* SANE
* XMPP
* DiskLess
* eGW etc

# Upgrade
* export old LDAP data (users, hosts (dhcp))
* import

# TODO:
* CentOS7 zero ISO
* CentOS LDAP ISO
* mk_all.sh
