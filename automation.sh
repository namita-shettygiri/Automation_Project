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
