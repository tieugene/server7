IPA
 
 * /etc/hosts:
```192.168.0.1 server.lan server```
 * instal rpms:
```yum -y install ipa-server-dns ipa-server-trust-ad [ipa-server bind bind-dyndb-ldap]```
 * go:
```ipa-server-install -N --setup-dns```
 * or:
```ipa-server-install -r LAN -n lan -p tratatata -a tratatata --mkhomedir --hostname=server.lan -N --setup-dns --forwarder=8.8.8.8 --reverse-zone=0.168.192.in-addr.arpa.
--zonemgr=...
```
  * resume:
```
Next steps:
        1. You must make sure these network ports are open:
                TCP Ports:
                  * 80, 443: HTTP/HTTPS
                  * 389, 636: LDAP/LDAPS
                  * 88, 464: kerberos
                  * 53: bind
                UDP Ports:
                  * 88, 464: kerberos
                  * 53: bind

        2. You can now obtain a kerberos ticket using the command: 'kinit admin'
           This ticket will allow you to use the IPA tools (e.g., ipa user-add)
           and the web user interface.
        3. Kerberos requires time synchronization between clients
           and servers for correct operation. You should consider enabling ntpd.

Be sure to back up the CA certificates stored in /root/cacert.p12
These files are required to create replicas. The password for these
files is the Directory Manager password
```
  * web: admin:tratatata@http://server/ipa/
  * ldap: cn=Directory Manager:tratatata@dc=lan
= Resume =
Нифига не понятно как с этим работать
