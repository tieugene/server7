#!/bin/sh
# mk_users.sh - bulk user creation in ldap
MIN=0
MAX=30
for ((n=$MIN;n<=$MAX;n++)); do
    i=$(printf "%02d" $n)
    echo "\
dn: uid=user$i,ou=Users,dc=lan
objectClass: top
objectClass: posixAccount
objectClass: person
objectClass: organizationalPerson
objectClass: inetOrgPerson
cn: cn$i
sn: sn$i
uid: user$i
uidNumber: 10$i
gidNumber: 100
loginShell: /bin/sh
homeDirectory: /mnt/shares/home/user$i
" | ldapadd -x -D "cn=odmin" -w tratatata -h localhost
ldappasswd  -x -D "cn=odmin" -w tratatata -h localhost -s pass$i uid=user$i,ou=Users,dc=lan
done
