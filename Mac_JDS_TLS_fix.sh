#!/bin/bash

# Check if running as Root/with sudo

if [ $EUID != 0 ];
  then
    echo "Please run this script as Root or with Sudo. Exiting."
    exit
fi

# Create a backup of 0000_127.0.0.1_34543_.conf and then update

echo "Creating a backup of /Library/Server/Web/Config/apache2/sites/0000_127.0.0.1_34543_.conf as 0000_127.0.0.1_34543_.conf.original"
cd /Library/Server/Web/Config/apache2/sites/
cp ./0000_127.0.0.1_34543_.conf ./0000_127.0.0.1_34543_.conf.original

# sed on MacOS requires that you make a backup when doing inline changes. Since we
# already made a copy before any changes, we'll delete these .bak copies afterwards

echo "Updating /Library/Server/Web/Config/apache2/sites/0000_127.0.0.1_34543_.conf"
sed -i.bak 's/MSTProtocolRange.*/MSTProtocolRange TLSv1 TLSv1.1 TLSv1.2 TLSv1.2/g' ./0000_127.0.0.1_34543_.conf
sed -i.bak 's/MSTProxyProtocolRange.*/MSTProxyProtocolRange TLSv1 TLSv1.1 TLSv1.2 TLSv1.2/g' ./0000_127.0.0.1_34543_.conf
rm ./0000_127.0.0.1_34543_.conf.bak

# Check if httpd.conf exists, if so, create a backup and then update

if [ -e /Library/Server/Web/Config/apache2/httpd.conf ];
  then
    echo "Creating a backup of /Library/Server/Web/Config/apache2/httpd.conf as httpd.conf.original"
    cd /Library/Server/Web/Config/apache2/
    cp ./httpd.conf ./httpd.conf.original

    echo "Updating /Library/Server/Web/Config/apache2/httpd.conf"
    sed -i.bak 's/SSLProtocol.*/SSLProtocol -all +TLSv1 +TLSv1.1 +TLSv1.2/g' ./httpd.conf
    rm ./httpd.conf.bak

  else
    echo "/Library/Server/Web/Config/apache2/httpd.conf doesn't exist. Skipping."
fi

# Create a backup of /Library/Server/Web/Config/apache2/httpd_server_app.conf and then update

echo "Creating a backup of /Library/Server/Web/Config/apache2/httpd_server_app.conf as httpd_server_app.conf.original"
cd /Library/Server/Web/Config/apache2/
cp ./httpd_server_app.conf ./httpd_server_app.conf.original

echo "Updating /Library/Server/Web/Config/apache2/httpd_server_app.conf"
sed -i.bak 's/SSLProtocol.*/SSLProtocol -all +TLSv1 +TLSv1.1 +TLSv1.2/g' ./httpd_server_app.conf
sed -i.bak 's/MSTProtocolRange.*/MSTProtocolRange TLSv1 TLSv1.1 TLSv1.2 TLSv1.2/g' ./httpd_server_app.conf
rm ./httpd_server_app.conf.bak

# Create a backup of /Library/Server/Web/Config/Proxy/apache_serviceproxy.conf and then update

echo "Creating a backup of /Library/Server/Web/Config/Proxy/apache_serviceproxy.conf as apache_serviceproxy.conf.original"
cd /Library/Server/Web/Config/Proxy/
cp ./apache_serviceproxy.conf ./apache_serviceproxy.conf.original

echo "Updating /Library/Server/Web/Config/Proxy/apache_serviceproxy.conf"
sed -i.bak 's/SSLProtocol.*/SSLProtocol -all +TLSv1 +TLSv1.1 +TLSv1.2/g' ./apache_serviceproxy.conf
sed -i.bak 's/SSLProxyProtocol.*/SSLProxyProtocol -all +TLSv1 +TLSv1.1 +TLSv1.2/g' ./apache_serviceproxy.conf
sed -i.bak 's/MSTProtocolRange.*/MSTProtocolRange TLSv1 TLSv1.1 TLSv1.2 TLSv1.2/g' ./apache_serviceproxy.conf
sed -i.bak 's/MSTProxyProtocolRange.*/MSTProxyProtocolRange SSLv2 SSLv3 TLSv1 TLSv1.1 TLSv1.2 TLSv1.2/g' ./apache_serviceproxy.conf
rm ./apache_serviceproxy.conf.bak

# Restart Apache so that the changes are applied

echo "Restarting Apache."
/usr/sbin/apachectl restart
