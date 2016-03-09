#!/bin/sh
# mk_hosts.sh - bulk ldap hosts creation
MIN=2
MAX=253
for ((n=MIN;n<=$MAX;n++)); do
    i=$(printf "%03d" $n)
    echo "\
dn: relativeDomainName=host$i,zoneName=lan,ou=DNS,dc=lan
objectClass: top
objectClass: dNSZone
zoneName: lan
relativeDomainName: host$i
dNSClass: IN
aRecord: 192.168.0.$n

dn: relativeDomainName=$n,zoneName=0.168.192.in-addr.arpa,ou=DNS,dc=lan
objectClass: top
objectClass: dNSZone
zoneName: 0.168.192.in-addr.arpa
relativeDomainName: $n
pTRRecord: host$i.lan.
" | ldapadd -x -D "cn=odmin,dc=lan" -w secred -h localhost
done
