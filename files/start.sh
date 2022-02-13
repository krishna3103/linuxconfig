#!/bin/bash

#
#/usr/sbin/nginx -g "daemon off;" &
service php7.4-fpm start

# Start apache
/usr/sbin/apache2 -D FOREGROUND
