#!/bin/bash
echo " welcome to the automatic installation by https://www.facebook.com/Jawes.01 (Dao Manh Hung)"
sleep 10;
# package updates
sudo yum check-update
sudo yum update 
# apache installation, enabling and status check
sudo yum -y install httpd
sudo systemctl start httpd
sudo systemctl enable httpd
sudo systemctl status httpd | grep Active
# firewall installation, start and status check
sudo yum install firewalld
sudo systemctl start firewalld
sudo systemctl status firewalld | grep Actives
# adding http and https services
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
# reloading the firewall
sudo firewall-cmd --reload
# acquiring the ip address for access to the web server
echo "this is the public IP address:" `curl -4 icanhazip.com`
# adding the needed permissions for creating and editing the index.html file
sudo chown -R $USER:$USER /var/www
# creating the html landing page
cd /var/www/html/
echo '<!DOCTYPE html>' > index.html
echo '<html>' >> index.html
echo '<head>' >> index.html
echo '<title>Level It Up</title>' >> index.html
echo '<meta charset="UTF-8">' >> index.html
echo '</head>' >> index.html
echo '<body>' >> index.html
echo '<h1>Welcome to Tran Quoc Khanh</h1>' >> index.html
echo '<h3>Red Team</h3>' >> index.html
echo '</body>' >> index.html
echo '</html>' >> index.html
echo " install Apache2 success"
sleep 10;
yum install bind bind-utils -y
sleep 2;
echo "khanhtq.local" > /etc/hostname
echo "HOSTNAME=khanhtq.local" > /etc/sysconfig/network
sleep 2;
systemctl stop firewalld
echo "172.16.0.99 khanhtq.local" >> /etc/hosts
sed -i 's/127.0.0.1;/127.0.0.1; 172.16.0.99; /' /etc/named.conf
zones=/etc/named.rfc1912.zones
cat > $zones <<EOF 

zone "khanhtq.local" IN {
        type master;
        file "db.khanhtq.local";
};

zone "0.16.172.in-addr.arpa" IN {
        type master;
        file "db.172.16.0";
};
EOF
sleep 2;
cp /var/named/named.localhost /var/named/db.khanhtq.local
cp /var/named/named.loopback /var/named/db.172.16.0
sleep 2;
dbl=/var/named/db.khanhtq.local
cat > $dbl <<EOF
$TTL 1D
@       IN SOA  dns.khanhtq.local.      root.khanhtq.local. (
                                        0       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
                IN              NS              dns.khanhtq.local.
                IN              A               172.16.0.99
dns             IN              A               172.16.0.99
khanhtq.local.  IN              A               172.16.0.99
www             IN              A               172.16.0.99
ftp             IN              CNAME           www
EOF
sleep 2;
db1=/var/named/db.172.16.0
cat > $db1 <<EOF
$TTL 1D
@       IN SOA  dns.khanhtq.local.      root.khanhtq.local. (
                                        0       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
        NS      dns.khanhtq.local.
99      IN PTR  dns.khanhtq.local.
EOF

sleep 2;
chown named:named db.khanhtq.local
chown named:named db.172.16.0
sleep 2;
reso=/etc/resolv.conf
cat > $ reso <<EOF
nameserver 172.16.0.99
nameserver 8.8.8.8
EOF
service named restart
service httpd restart
echo " install DNS success "
sleep 10;
yum install dhcp -y
cp /usr/share/doc/dhcp-4.2.5/dhcpd.conf.example /etc/dhcp/dhcpd.conf
dhcp=/etc/dhcp/dhcpd.conf
cat > $dhcp <<EOF
subnet 172.16.0.0 netmask 255.255.255.0 {
         option routers                  172.16.0.2; # địa chỉ gateway
         option subnet-mask              255.255.255.0; # subnet mask gateway
         option domain-name              "khanhtq.local"; # tên domain
         option domain-name-servers      172.16.0.99; # địa chỉ DNS Server
         option time-offset              -18000;     # Eastern Standard Time
         range 172.16.0.10 172.16.0.100; # miền IP được gán tự động cho client
}
EOF
echo " install DHCP success"
sleep 10;
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

</VirtualHost>
EOF
sleep 2;
redic=/etc/httpd/conf.d/redirect.conf
cat > $redic <<EOF
<VirtualHost *:80>
        Servername 172.16.0.99:80
        Redirect "/" "https://172.16.0.99"
</VirtualHost>
EOF
sleep 2;
systemctl restart httpd
echo " install SSL success"
sleep 10;
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
#Client
#mkdir /mnt/nfs
#mount -t nfs 172.16.0.99:/share-data /mnt/nfs/
echo " install NFS success"
sleep 10;
yum install epel-release -y
sleep 2; 
yum install postfix -y
sleep 2;
sed -i 's/#myhostname = virtual.domain.tld/myhostname = mail.khanhtq.local/' /etc/postfix/main.cf
sed -i 's/#mydomain = domain.tld/mydomain =   khanhtq.local/' /etc/postfix/main.cf
sed -i 's/#myorigin = $mydomain/myorigin = $mydomain/' /etc/postfix/main.cf
sed -i 's/#inet_interfaces = all/inet_interfaces = all/' /etc/postfix/main.cf
sed -i 's/#mydestination = $myhostname, localhost.$mydomain, localhost, $mydomain/mydestination = $myhostname, localhost.$mydomain, localhost, $khanhtq.local/' /etc/postfix/main.cf
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
echo "NHAP Values"
sleep 10;


