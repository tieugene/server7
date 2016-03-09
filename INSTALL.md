# 0: Zero

## Desc:
* / only
* extremally thin (w/o selinux NM; 833M, 231 rpms)
* += dnf mc rpmreaper net-tools chrony man-db wget telnet git patch
* net: 192.168.0.1, server.lan
* updated to 2016-03-02

## TODO:
* yum -y install epel-release
* yum install dnf mc rpmreaper net-tools chrony man-db wget telnet git patch
* dnf update
* systemctl enable chronyd.service; systemctl start chronyd.service
* /etc/sysconfig/selinux: disabled;
* /etc/fstab: /dev/vda
* rpmreaper
* yum clean all; dnf clean all; dd if=/dev/zero of=/bigfile bs=1M; rm -f /bigfile

# 1: LDAP

## Desc:
Nothing

## TODO:
* caches: ln -s /var/cahce/{dnf,yum}
* install packages:
```
dnf install\
openldap-servers\
openldap-clients\
nss-pam-ldapd\
authconfig\
bind-sdb-chroot\
[bind-dyndb-ldap]\
dhcpd\
smbldap-tools\
samba-dc\
dovecot\
postfix
```
* Prepare:
HOWTO: http://www.server-world.info/en/note?os=CentOS_7&p=openldap
```
cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG
chown ldap. /var/lib/ldap/DB_CONFIG
systemctl start slapd
systemctl enable slapd
sh/init_ldap.sh
```
# 2. PAM
* packages: authconfig nss-pam-ldap
* create LDAP entries:
```
ldap_add.sh Users.ldif
mk_users.sh
```
* configure pam:
```
authconfig --enableldap --enableldapauth --disablenis --enablecache --ldapserver=localhost --ldapbasedn=dc=lan --updateall
```
* /etc/openldap/ldap.conf:
```
tls_cacertdir /etc/openldap/cacerts
uri ldap://localhost/
base dc=ldap
# added
#host 127.0.0.1
scope sub
pam_filter objectclass=posixAccount
pam_login_attribute uid
pam_password exop
nss_base_passwd ou=Users,dc=lan?one
nss_base_shadow ou=Users,dc=lan?one
nss_base_group  ou=Groups,dc=lan?one
nss_initgroups_ignoreusers root,ldap
ssl no
pam_password md5
```
* Enable services:
```
systemctl enable nscd && systemctl start nscd
systemctl enable nslcd && systemctl start nslcd
```
* Activate changes:
```init 6```
* Create homes:
```
mkdir -p /mnt/shares/home
for i in `getent passwd | gawk -F'[/:]' '{print $1}' | grep ^user`; do mkdir /mnt/shares/home/$i; chown $i:users /mnt/shares/home/$i; done
```
# 3. DNS
* packages: bind-sdb bind-utils
* convert schema (http://technik.blogs.nde.ag/2012/08/19/converting-and-adding-openldap-schema-files/):
```
dnszone_schema2ldif.sh
```
* add schema:
```ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/dnszone.ldif```
* add records:
```
# DNS, server, gw tp LDAP
sh/ldap_add.sh ldif/2-DNS.ldif
# other
sh/mk_hosts.sh
```
* configure named:
```
# patch /etc/named.conf:
# patch /etc/sysconfig/named:
```+ENABLE_SDB=yes```
# patch /etc/resolve.conf:
* service:
```systemctl enable named-sdb && systemctl start named-sdb```
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
schema2ldif.sh /etc/openldap/schema/dhcp.schema
mv ~/dhcp.ldif /etc/openldap/schema/
```
* add schema:
```ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/dhcp.ldif```
* add LDAP entries:
```
sh/ldap_add.sh ldif/3-DHCP.ldif
sh/mk_dhcp.sh
```
* configure:
```patch /etc/dhcp/dhcpd.conf```
* start service:
```systemctl enable dhcpd && systemctl start dhcpd```
* check

# 5. SAMBA
# 6. IMAP/POP3
# 7. SMTP
# 8. Proxy
# 9. FTP (pureftpd)
# 10. HTTP
# 11. WebDAV
# 12. XMPP
# Non-LDAP:
## NFS
# Addons
* CUPS
* SANE
* DiskLess
* eGW etc

# Upgrade
* export old LDAP data (users, hosts (dhcp)
* import

# TODO:
* CentOS7 zero ISO
* CentOS LDAP ISO
* mk_all.sh
