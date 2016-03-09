#!/bin/bash

# convert OpenLDAP dnszone schema file to LDIF file
#
# Copyright 2012 NDE Netzdesign und -entwicklung AG, Hamburg
# Written by Jens-U. Mozdzen <jmozdzen@nde.ag>
# updated by TI_Eugene <ti.eugene@gmail.com>
#
# Permission is granted to use, modify and redistribute this file as long as
# - this copyright notice is left unmodified and included in the final code
# - the original author is notified via email if this code is re-distributed as part of a paid-for deliverable
# - the original author is not held liable for any damage, loss of profit, efforts or inconvenience of any sorts
#   that may result from using, modifying or redistributing this software.
#
# Use at your own risk - this code may not be suitable for your needs or even cause damage when used.
# If you find any problems with this code, please let the author know so that it can be fixed or at least others
# can be warned.
#
# Usage: schema2ldif_dnszone.sh
# 
# This program will try to convert the source file to an LDIF-style file, placing the resulting .ldif file
# in the current directory.

rc=0

slaptest=$(which slaptest 2>/dev/null ||ls /usr/sbin/slaptest||echo "")
if [ -x $slaptest ] ; then
	schemaFile="/etc/openldap/schema/dnszone.schema"
	#localdir=$(pwd)
	if [ -r $schemaFile ] ; then
		targetFile="/etc/openldap/schema/dnszone.ldif"
		if [ ! -e $targetFile ] ; then
			echo "$0: converting $schemaFile to LDIF $targetFile"
			# create temp dir and config file
			tmpDir=$(mktemp -d)
			cd $tmpDir
			echo "include /etc/openldap/schema/core.schema
include /etc/openldap/schema/cosine.schema
include /etc/openldap/schema/nis.schema
include /etc/openldap/schema/inetorgperson.schema
include /etc/openldap/schema/dnszone.schema" > tmp.conf
			# convert
			$slaptest -f tmp.conf -F $tmpDir
			# 3. rename and sanitize
			cd cn\=config/cn\=schema
			filenametmp="cn={4}dnszone.ldif"
			sed -r -e  's/^dn: cn=\{4\}(.*)$/dn: cn=\1,cn=schema,cn=config/' \
				-e 's/cn: \{4\}(.*)$/cn: \1/' \
				-e '/^structuralObjectClass: /d' \
				-e '/^entryUUID: /d' \
				-e '/^creatorsName: /d' \
				-e '/^createTimestamp: /d' \
				-e '/^entryCSN: /d' \
				-e '/^modifiersName: /d' \
				-e '/^modifyTimestamp: /d' < $filenametmp > $targetFile

			# clean up
			echo "$0: LDIF file successfully created as $targetFile"
			rc=0
			rm -rf $tmpDir
		else
			echo "$0: target file $targetFile already exists, aborting." >&2
			rc=3
		fi
	else
		echo "$0: source file $schemaFile could not be read, aborting." >&2
		rc=2
	fi
else
	echo "$0: could not locate slaptest binary, exiting." >&2
	rc=1
fi

exit $rc
