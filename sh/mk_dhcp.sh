#!/bin/sh
# mk_dhcp.sh - bulk ldap dhcp hosts creation
MIN=2
MAX=253
for ((n=MIN;n<=$MAX;n++)); do
    i=$(printf "%03d" $n)
    echo "\
dn: cn=host$i,cn=Static,cn=192.168.0.0,cn=config,cn=server.lan,ou=DHCP,dc=lan
objectClass: top
objectClass: dhcpHost
cn: host$i
dhcpHWAddress: ethernet FF:FF:FF:FF:FF:FF
dhcpStatements: fixed-address host$i
" | ldapadd -x -D "cn=odmin,dc=lan" -w secred -h localhost
done
