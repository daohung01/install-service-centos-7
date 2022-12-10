#!bin/bash
touch /taouser
chmod +x /taouser
dir=/taouser
cat > $dir <<EOF
#!bin/bash
useradd $1
passwd $1
echo "by https://github.com/daohung01"
EOF
sleep 2;
export PATH="/taouser/bin:$PATH"
