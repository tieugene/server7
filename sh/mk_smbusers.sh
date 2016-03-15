#!/bin/sh
# make all users smb-compatible
for i in `getent passwd | gawk -F'[/:]' '{print $1}' | grep ^user | sort`
do
    smbldap-usermod -a $i
    PASS=pass`echo $i | cut -b 5-6`
    echo $PASS | smbldap-passwd -s -p $i
    smbldap-groupmod -m $i Domain\ Users
    mkdir /mnt/shares/profiles/$i
    chown $i:users /mnt/shares/profiles/$i
    mkdir /mnt/shares/private/$i
    chown $i:users /mnt/shares/private/$i
done
