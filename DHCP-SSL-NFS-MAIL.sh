#!/bin/bash
yum install dhcp -y
cp /usr/share/doc/dhcp-4.2.5/dhcpd.conf.example /etc/dhcp/dhcpd.conf
dhcp=/etc/dhcp/dhcpd.conf
cat > $dhcp <<EOF
subnet 172.16.0.0 netmask 255.255.255.0 {
         option routers                  172.16.0.2; # địa chỉ gateway
         option subnet-mask              255.255.255.0; # subnet mask gateway
         option domain-name              "hungdn.local"; # tên domain
         option domain-name-servers      172.16.0.99; # địa chỉ DNS Server
         option time-offset              -18000;     # Eastern Standard Time
         range 172.16.0.10 172.16.0.100; # miền IP được gán tự động cho client
}
EOF
sleep 2;
mkdir /root/mycerts
cd mycerts/
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout web.key -out web.crt
mkdir /etc/httpd/sslcerts
cp /root/mycerts/web.* /etc/httpd/sslcerts/
cd /etc/httpd/sslcerts/
yum install mod_ssl -y
sleep 2;
ssl=/etc/httpd/conf.d/ssl.conf
cat > $ssl <<EOF
Listen 443 https

SSLPassPhraseDialog exec:/usr/libexec/httpd-ssl-pass-dialog
SSLSessionCache         shmcb:/run/httpd/sslcache(512000)
SSLSessionCacheTimeout  300
SSLRandomSeed startup file:/dev/urandom  256
SSLRandomSeed connect builtin
SSLCryptoDevice builtin
<VirtualHost _default_:443>
ErrorLog logs/ssl_error_log
TransferLog logs/ssl_access_log
LogLevel warn
SSLEngine on
SSLProtocol all -SSLv2 -SSLv3
SSLCipherSuite HIGH:3DES:!aNULL:!MD5:!SEED:!IDEA
SSLCertificateFile /etc/httpd/sslcerts/web.crt
SSLCertificateKeyFile /etc/httpd/sslcerts/web.key
<Files ~ "\.(cgi|shtml|phtml|php3?)$">
    SSLOptions +StdEnvVars
</Files>
<Directory "/var/www/cgi-bin">
    SSLOptions +StdEnvVars
</Directory>
BrowserMatch "MSIE [2-5]" \
         nokeepalive ssl-unclean-shutdown \
         downgrade-1.0 force-response-1.0
CustomLog logs/ssl_request_log \
          "%t %h %{SSL_PROTOCOL}x %{SSL_CIPHER}x \"%r\" %b"
sleep 2;
#!/bin/bash
yum install nfs-utils -y 
mkdir /share-data
chmod -R 755 /share-data
chown nfsnobody:nfsnobody /share-data
systemctl enable rpcbind
systemctl enable nfs-server
systemctl enable nfs-lock
systemctl enable nfs-idmap

systemctl start rpcbind
systemctl start nfs-server
systemctl start nfs-lock
systemctl start nfs-idmap
sleep 2;
echo "/share-data    172.16.0.0/24(rw,sync,no_root_squash,no_all_squash)" >> /etc/exports
systemctl restart nfs-server
sleep2;
yum install epel-release -y
sleep 2; 
yum install postfix -y
sleep 2;
sed -i 's/#myhostname = virtual.domain.tld/myhostname = mail.hungdn.local/' /etc/postfix/main.cf
sed -i 's/#mydomain = domain.tld/mydomain =   hungdn.local/' /etc/postfix/main.cf
sed -i 's/#myorigin = $mydomain/myorigin = $mydomain/' /etc/postfix/main.cf
sed -i 's/#inet_interfaces = all/inet_interfaces = all/' /etc/postfix/main.cf
sed -i 's/#mydestination = $myhostname, localhost.$mydomain, localhost, $mydomain/mydestination = $myhostname, localhost.$mydomain, localhost, $hungdn.local/' /etc/postfix/main.cf
sleep 2;
echo "mynetworks = 172.16.0.0/24, 127.0.0.0/8, 0.0.0.0/0, 192.168.1.0/24" >> /etc/postfix/main.cf
systemctl enable postfix 
systemctl restart postfix
sleep 2;
yum install net-tools -y
sleep 2;
yum install dovecot -y  
sleep 2;
echo "   mail_location = maildir:~/Maildir" >> /etc/dovecot/conf.d/10-mail.conf
sed -i 's/#disable_plaintext_auth = yes/disable_plaintext_auth = yes/' /etc/dovecot/conf.d/10-auth.conf
sed -i 's/auth_mechanisms = plain/auth_mechanisms = plain login/' /etc/dovecot/conf.d/10-auth.conf
sleep 2;
pfix=/etc/dovecot/conf.d/10-master.conf
cat > $pfix <<EOF
service imap-login {
  inet_listener imap {
  }
  inet_listener imaps {
  }
}

service pop3-login {
  inet_listener pop3 {
  }
  inet_listener pop3s {
  }
}

service lmtp {
  unix_listener lmtp {
  }
}

service imap {
}

service pop3 {
}

service auth {
  unix_listener auth-userdb {
    user = postfix
    group = postfix
  }
}

service auth-worker {
}

service dict {
  unix_listener dict {
  }
}
EOF
sleep 2;
systemctl restart dovecot
systemctl enable dovecot
sleep 2;
yum install squirrelmail -y
sleep 2;


# NHAP TAY GIA TRI ROI RUN TIEP
./conf.pl /usr/share/squirrelmail/config/




# 1-1-hungdnt-4-Welcome To Webmail-7-https://hungdn.local-8-hungdn-R-2-1-hungdn.local
#-3-2-S-Q
#!/bin/bash
#squi=/etc/httpd/conf/httpd.conf
#cat >> $squi <<EOF
#Alias /squirrelmail /usr/share/squirrelmail
#<Directory /usr/share/squirrelmail>
#Options Indexes FollowSymLinks
#RewriteEngine On
#AllowOverride All
#DirectoryIndex index.php
#Order allow,deny
#Allow from all
#</Directory>
#EOF
#sleep 2;
#systemctl restart httpd
#touch /etc/named.conf/hungdn.local.zone
#/usr/sbin/setsebool httpd_can_network_connect=1 #Permission Login MailServer
