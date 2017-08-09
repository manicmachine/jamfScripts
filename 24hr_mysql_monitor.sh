#!/bin/sh

##########################################################################################
# This script will continuously query MySQL every second over 24 hours for its full      #
# process list. In order for this to run properly, the client machine will need to have  #
# a local MySQL binary and be able to reach the MySQL server.                            #
##########################################################################################

# Update these as needed
mysql_username='jamfsoftware'
mysql_password='jamfsw03'
mysql_hostname='your.mysql.fqdn'

############################ Don't edit below this line ################################## 
##########################################################################################

# Determine if running on Mac OS or Linux and assign binary path accordingly. 
mysql_binary_path=$(if [ `uname` = 'Darwin' ]
then
	echo "/usr/local/mysql/bin/mysql"
else
	echo "/usr/bin/mysql"
fi)

# Verify local binary exists. If not, exit the script.
if [ ! -e $mysql_binary_path ]
then
	echo "MySQL binary not found at $mysql_binary_path. Quitting" | tee -a ~/mysql_process.log
	exit
fi

# Query MySQL for it's full process list sorted by the age of the 
# process. Append the output to ~/mysql_process.log and then sleep for 1 second.

counter=0

while [ $counter -lt 86400 ]
do
    date >> ~/mysql_process.log
	$mysql_binary_path -u $mysql_username -p$mysql_password -h $mysql_hostname -e 'SELECT * FROM information_schema.processlist ORDER BY time ASC;' 2>&1 | grep -vi "using a password" >> ~/mysql_process.log
   	echo "<----->" >> ~/mysql_process.log
   	counter=$((counter+1))
   	sleep 1
done