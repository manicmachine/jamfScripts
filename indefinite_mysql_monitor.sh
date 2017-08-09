#!/bin/sh

##########################################################################################
# This script will continuously query MySQL every second for its full process list.      #
# It will automatically create a new log file for each day it's running until cancelled. #
# In order for this to run properly, the client machine will need to have a local MySQL  #
# binary and be able to reach the MySQL server.                                          #
##########################################################################################

# Update these as needed
mysql_username='jamfsoftware'
mysql_password='jamfsw03'
mysql_hostname='your.mysql.fqdn'

############################ Don't edit below this line ##################################
##########################################################################################

day=`date "+%m-%d"`

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
	echo "MySQL binary not found at $mysql_binary_path. Quitting" | tee -a ~/mysql_process_$day.log
	exit
fi

# Update the date, then query MySQL for it's full process list sorted by the age of the
# process. Append the output to ~/mysql_process_$day.log and then sleep for 1 second.
while true
do
	day=`date "+%m-%d"`

    date >> ~/mysql_process_$day.log
	$mysql_binary_path -u $mysql_username -p$mysql_password -h $mysql_hostname -e 'SELECT * FROM information_schema.processlist ORDER BY time ASC;' 2>&1 | grep -vi "using a password" >> ~/mysql_process_$day.log
   	echo "<----->" >> ~/mysql_process_$day.log
   	sleep 1
done
