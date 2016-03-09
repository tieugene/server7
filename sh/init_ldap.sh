#!/bin/sh

# 0. gen password
PASS=`slappasswd -s secred`

# 1. chg root password
echo "\
dn: olcDatabase={0}config,cn=config
changetype: modify
add: olcRootPW
olcRootPW: $PASS
" | ldapadd -Y EXTERNAL -H ldapi:///

# 2. import schemas
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif

# 3. chg LDAP mgr:
echo "\
dn: olcDatabase={1}monitor,cn=config
changetype: modify
replace: olcAccess
olcAccess: {0}to * by dn.base=\"gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth\"
  read by dn.base=\"cn=odmin,dc=lan\" read by * none

dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcSuffix
olcSuffix: dc=lan

dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcRootDN
olcRootDN: cn=odmin,dc=lan

dn: olcDatabase={2}hdb,cn=config
changetype: modify
add: olcRootPW
olcRootPW: $PASS

dn: olcDatabase={2}hdb,cn=config
changetype: modify
add: olcAccess
olcAccess: {0}to attrs=userPassword,shadowLastChange by
  dn=\"cn=odmin,dc=lan\" write by anonymous auth by self write by * none
olcAccess: {1}to dn.base=\"\" by * read
olcAccess: {2}to * by dn=\"cn=odmin,dc=lan\" write by * read
" | ldapmodify -Y EXTERNAL -H ldapi:///
