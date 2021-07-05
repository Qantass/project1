#!/bin/bash
sed -e "s/mysql_ip/$1/g" host_1 >hosts
sed -i "s/tomcat_ip/$2/g" hosts