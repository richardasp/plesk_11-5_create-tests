#!/bin/bash

###   add IP's section
for x in 4 5 6; do /usr/local/psa/bin/ipmanage --create 192.168.99.10$x -mask 255.255.255.0 -interface eth0 -type exclusive; done
for x in 1; do /usr/local/psa/bin/ipmanage --create 192.168.99.10$x -mask 255.255.255.0 -interface eth0 -type shared; done

### add clients and resellers
for x in 7 8 9; do /usr/local/psa/bin/customer --create migclient$x -name "Migration User$x" -passwd sample -email c$x@client$x.com -country us -notify false; done
for x in 7 8 9; do /usr/local/psa/bin/reseller --create migreseller$x -name "Reseller User$x" -passwd sample -email r$x@reseller$x.net -country US -notify false; done
for y in 7 8 9; do for x in 4 5 6; do /usr/local/psa/bin/customer --create migclient$y$x -name "Res Client$y$x" -passwd sample -email c$x@resclient$y.com -country us -owner migreseller$y -notify false; done; done

### add service plans for resellers
for x in 7 8 9; do /usr/local/psa/bin/service_plan -c "Personal Sites Reseller $x" -hosting true -disk_space 500M -max_traffic 1G -owner migreseller$x; done

###  add service plans to test with
/usr/local/psa/bin/service_plan -c "Personal Sites Clients" -hosting true -disk_space 555M -max_traffic 4096M -max_box 100 -mbox_quota 2G -quota 3G -max_wu 5 -max_subftp_users 6 -max_db 7 -max_maillists 8 -max_subdom 9 -max_site 10 -maillist true -php true -cgi true -perl true -webstat webalizer -webstat awstats -webstat_protdir true  -dns_zone_type master -manage_crontab true -manage_subdomains true  -manage_sh_access true -manage_domain_aliases true -shell /bin/sh

### add hosting domains to the clients
for x in 7; do /usr/local/psa/bin/subscription --create example$x.com -owner migclient$x -service-plan "Default Domain" -ip 192.168.99.101 -login clientuser$x -passwd "userpass" -hosting true -notify false; /usr/local/psa/bin/mail --create migclient$x.user@example$x.com -passwd mypass -mbox_quota 50M -mailbox true;  /usr/local/psa/bin/database --create migration$x -domain example$x.com -server localhost:3306 -type mysql -add_user migcl_user$x -passwd simple; done

for x in 8 9; do /usr/local/psa/bin/subscription --create example$x.com -owner migclient$x -service-plan "Personal Sites Clients" -ip 192.168.99.101 -login clientuser$x -passwd "userpass" -hosting true -notify false; /usr/local/psa/bin/mail --create migclient$x.user@example$x.com -passwd mypass -mbox_quota 50M -mailbox true;  /usr/local/psa/bin/database --create migration$x -domain example$x.com -server localhost:3306 -type mysql -add_user migcl_user$x -passwd simple; done


for x in 7 8 9; do /usr/local/psa/bin/subscription --create resexample$x.com -owner migreseller$x -service-plan "Personal Sites Reseller $x" -ip 192.168.99.101 -login reselleruser$x -passwd "userpass" -hosting true -notify false; /usr/local/psa/bin/mail --create migreseller$x.user@resexample$x.com -passwd mypass -mbox_quota 50M  -mailbox true;  /usr/local/psa/bin/database --create resmigration$x -domain resexample$x.com -server localhost:3306 -type mysql -add_user resmigcl_user$x -passwd simple; done

for y in 7 8 9; do for x in 4 5 6; do /usr/local/psa/bin/subscription --create resclientexample$y$x.com -owner  migclient$y$x -ip 192.168.99.101 -login reselleruser$y$x -passwd "userpass" -hosting true -notify false; /usr/local/psa/bin/mail --create reselleruser$y$x.user@resclientexample$y$x.com -passwd mypass -mbox_quota 50M  -mailbox true; /usr/local/psa/bin/database --create resclientmigration$y$x -domain resclientexample$y$x.com -server localhost:3306 -type mysql -add_user rescl_user$y$x -passwd simple; done; done

### update root clients service plans
for x in 8 9; do /usr/local/psa/bin/subscription --update example$x.com -service-plan "Personal Sites Clients"  -notify false; done

### update reseller clients service plans
for x in 7 8 9; do /usr/local/psa/bin/service_plan -u "Personal Sites Reseller $x" -quota 10G  -owner migreseller$x; done

### update reseller client service plan 
/usr/local/psa/bin/subscription --switch-subscription resclientexample85.com -service-plan "Personal Sites Reseller 8"
/usr/local/psa/bin/subscription --sync-subscription resclientexample85.com

### change shared IP to dedicated IP for reseller domains
/usr/local/psa/bin/ipmanage --update 192.168.99.104 -type shared
/usr/local/psa/bin/ip_pool --add 192.168.99.104 -type shared -owner migreseller9
/usr/local/psa/bin/ip_pool --add 192.168.99.106 -type exclusive -owner migreseller8
/usr/local/psa/bin/subscription --update resclientexample94.com  -notify false -ssl true -ip 192.168.99.104
/usr/local/psa/bin/subscription --update resclientexample84.com  -notify false -ssl true -ip 192.168.99.106

### change IP from shared to dedicated for client domains
for x in 7; do /usr/local/psa/bin/subscription --update example$x.com -ip 192.168.99.105  -ssl true  -notify false; done

### add subdomains
for x in 1 2 3; do /usr/local/psa/bin/subdomain -c sub$x -domain example7.com -ssi true -php true -ssl true -notify false; done

### add domain alias
/usr/local/psa/bin/domalias -c example8.net -domain example8.com -status enabled -mail true -notify false

### add mailing lists
/usr/local/psa/bin/maillist -c MailList -domain example9.com -passwd_type plain -passwd sample -notify false -email listadmin@example9.com

### add webusers
for x in 1 2 3;  do /usr/local/psa/bin/webuser -c johndoe$x -domain example9.com -passwd userpass -php true -quota 100M; done

### add ftpuser
/usr/local/psa/bin/ftpsubaccount --create JohnDoeFTP -domain example9.com -passwd userpass -home /httpdocs

### add another site to an existing customer
/usr/local/psa/bin/site -c example.org -webspace-name example9.com -hosting true -notify false

exit 0
