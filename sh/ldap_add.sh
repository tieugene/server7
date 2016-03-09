#!/bin/sh
# add file to LDAP
ldapadd -x -D "cn=odmin,dc=lan" -w secred -h localhost -p 389 -f $1
