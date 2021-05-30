#!/bin/bash

#update of the package details and the package list
apt update -y

#Install the apache2 package if it is not already installed
if ! apache2ctl -v > /dev/null
then
	apt-get install apache2 -y
fi

#Start apache2 service if not running
if ! pidof apache2 > /dev/null
then
	service apache2 restart
fi

#Enable apache2 service if not enabled
systemctl is-enabled apache2 > status.txt
if grep -q "disabled" status.txt
then
	systemctl enable apache2
fi

#Create a tar archive of apache2 access logs and error logs and place the tar into the /tmp/ directory with current timestamp
#Upload tar file to S3 bucket
timestamp=$(date '+%d%m%Y-%H%M%S')
myname="Namita"
s3_bucket="upgrad-namita"
tar -cvf /tmp/"$myname-httpd-logs-$timestamp".tar /var/log/apache2/*.log
aws s3 cp /tmp/${myname}-httpd-logs-${timestamp}.tar s3://${s3_bucket}

#Store the tar filesize in a variable and covert to kilobytes
filesize=$(stat --printf="%s" /tmp/"$myname-httpd-logs-$timestamp".tar)
filesize_KB=`expr $filesize / 1000`

#If inventory.html doesn't exist create the file with header and append the required values, else just append the values
if [[ ! -f /var/www/html/inventory.html ]]
then
	cd /var/www/html/
	touch inventory.html
	echo LogType$'\t\t'Time Created$'\t\t'Type$'\t\t'Size >> inventory.html
	echo httpd-logs$'\t\t'$timestamp$'\t\t'tar$'\t\t'$filesize >> inventory.html
else
	cd /var/www/html/
	echo httpd-logs$'\t\t'$timestamp$'\t\t'tar$'\t\t'$filesize_KB"K" >> inventory.html
fi

if [[ ! -f /etc/cron.d/automation ]]
then
	echo "0 0 * * * root /root/Automation_Project/automation.sh" >> /etc/cron.d/automation
fi
