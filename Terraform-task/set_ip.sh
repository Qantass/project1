#!/bin/bash
sed -e "s/mysql/$1/g" host_1 >hosts
sed -i "s/tomcat/$2/g" hosts