#!/bin/bash

apt update -y

conf=`dpkg --get-selections | grep apache`
if [ -z "$conf" ]
then
        apt-get -qq -y install apache2
else
	echo "Apache already installed"
fi

status=$(ps cax | grep apache2)
if [ -z "$status" ]
then
	echo "Apache is not running."
	/etc/init.d/apache2 start
else
	echo "Apache is running."
fi

systemctl enable apache2

cd /var/log/apache2/

timestamp=$(date '+%d%m%Y-%H%M%S')
myname='vikalp'
filename=$myname'-httpd-logs-'$timestamp'.tar'
s3bucket='upgrad-'$myname

tar -cvf /tmp/$filename access.log error.log

aws s3 cp /tmp/$filename s3://$s3bucket/$filename
