= 398-ds =
### LDAP
* LDAP:
(dc=lan)
 * instal packages:
```
dnf install 389-ds-base[ 389-admin
```
 * create user&group:
```
groupadd -g 55 ldap
useradd -c LDAP -d /var/lib/dirsrv -g 55 -s /sbin/nologin -u 55 ldap
passwd ldap
```
 * /etc/hosts:
```
192.168.0.1 server.lan
```
 * config ldap server:
```
setup-ds[_admin].pl:
 yes
 custom
 user: ldap;
 group: ldap;
 port: 389[/9830]
 [admin: admin:secred]
 DM DN: cn=odmin:tratatata
```
 * Go:
```
systemctl enable dirsrv.target
systemctl start dirsrv.target
systemctl status dirsrv.target
systemctl enable dirsrv-admin.service
```
* PAM:
 * create LDAP entries:
```
ldapadd -x -D "cn=odmin" -w tratatata -h localhost -p 389 -f Users.ldif
mk_users.sh
```
If must be additional groups: ...
 * install packages:
```
dnf install nss-pam-ldapd authconfig
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
init 6
```
 * create homes:
```
mkdir -p /mnt/shares/home
for i in `getent passwd | gawk -F'[/:]' '{print $1}' | grep ^user`; do mkdir /mnt/shares/home/$i; chown $i:users /mnt/shares/home/$i; done
```

= Resume =
ldappasswd error
