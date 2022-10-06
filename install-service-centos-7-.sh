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
echo '<h1>Welcome to Dao Manh Hung</h1>' >> index.html
echo '<h3>Red Team</h3>' >> index.html
echo '</body>' >> index.html
echo '</html>' >> index.html
echo " install Apache2 success"
sleep 10;
#!/bin/bash
yum install bind bind-utils -y
sleep 2;
echo "hungdn.local" > /etc/hostname
echo "HOSTNAME=hungdn.local" > /etc/sysconfig/network
sleep 2;
systemctl stop firewalld
echo "172.16.0.99 hungdn.local" >> /etc/hosts
sed -i 's/127.0.0.1;/127.0.0.1; 172.16.0.99; /' /etc/named.conf
zones=/etc/named.rfc1912.zones
cat > $zones <<EOF 

zone "hungdn.local" IN {
        type master;
        file "db.hungdn.local";
};

zone "0.16.172.in-addr.arpa" IN {
        type master;
        file "db.172.16.0";
};
EOF
sleep 2;
cp /var/named/named.localhost /var/named/db.thungdn.local
cp /var/named/named.loopback /var/named/db.172.16.0
sleep 2;
dbl=/var/named/db.hungdn.local
cat > $dbl <<EOF
$TTL 1D
@       IN SOA  hungdn.local.      root.hungdn.local. (
                                        0       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
                IN              NS              hungdn.local.
                IN              A               172.16.0.99
dns             IN              A               172.16.0.99
hungdn.local.   IN              A               172.16.0.99
www             IN              A               172.16.0.99
ftp             IN              CNAME           www
EOF
sleep 2;
db1=/var/named/db.172.16.0
cat > $db1 <<EOF
$TTL 1D
@       IN SOA  hungdn.local.      root.hungdn.local. (
                                        0       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
        NS      hungdn.local.
99      IN PTR  hungdn.local.
0       IN PTR  hungdn.local.
EOF

sleep 2;
chown named:named /var/named/db.hungdn.local
chown named:named /var/named/db.172.16.0
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
echo " susccess apache2 - DNS fix" 





