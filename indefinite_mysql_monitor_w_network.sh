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

mysql_port=3306 # Only change this if you don't use the default MySQL port.
check_network=True # Set to False if your network blocks both ping and port scans

############################ Don't edit below this line ################################## 
##########################################################################################

day=`date "+%m-%d"

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

# Check if we're able to reach MySQL via ping. If it fails, assume ping is ignored and 
# instead attempt to scan server on port 3306.
if [ $check_network = True ]
then	
	if ! ping -c 3 $mysql_hostname &> /dev/null
	then
		if ! nc -zw3 $mysql_hostname $mysql_port &> /dev/null
		then
			echo "Unable to reach MySQL server at $mysql_hostname on port $mysql_port. \nIf your network is blocking both ping and port scans, set check_network to False within the script and try again. Quitting" | tee -a ~/mysql_process_$day.log
			exit
		fi
	fi
fi

# Update the date, then query MySQL for it's full process list sorted by the age of the 
# process. Append the output to ~/mysql_process_$day.log and then sleep for 1 second.
while True
do
	day=`date "+%m-%d"`
	 
    date >> ~/mysql_process_$day.log
	$mysql_binary_path -u $mysql_username -p$mysql_password -h $mysql_hostname -e 'SELECT * FROM information_schema.processlist ORDER BY time ASC;' >> ~/mysql_process_$day.log 2> /dev/null
   	echo "<----->" >> ~/mysql_process_$day.log
   	sleep 1
done 