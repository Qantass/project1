#!/bin/bash

sed -i -r 's/.+mysql.+(\b[0-9]{1,3}\.){3}[0-9]{1,3}\b'/'linux_MySQL ansible_host='\"$1/g hosts.txt
sed -i -r 's/.+tomcat.+(\b[0-9]{1,3}\.){3}[0-9]{1,3}\b'/'linux_TomCAT ansible_host='\"$2/g hosts.txt