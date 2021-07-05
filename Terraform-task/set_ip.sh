#!/bin/bash
sed -i "s/mysql_ip/$1/g" hosts
sed -i "s/tomcat_ip/$2/g" hosts