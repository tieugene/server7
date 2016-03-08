#!/bin/sh
# script to make all-in-one:
# * install LDAP server etc
# * mk admin
# * create wanted entries
# * ...
# TODO:
# * options (user uids, dhcp)

if [ ! f /var/lib/ldap/DB_CONFIG ]:
    cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG
    chown ldap. /var/lib/ldap/DB_CONFIG
fi
systemctl enable slapd
systemctl start slapd
