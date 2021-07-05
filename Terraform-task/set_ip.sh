#!/bin/bash

sed -i -r 's/.+MySQL.+(\b[0-9]{1,3}\.){3}[0-9]{1,3}\b'/'linux_MySQL ansible_host='$1/g hosts.txt
sed -i -r 's/.+TomCAT.+(\b[0-9]{1,3}\.){3}[0-9]{1,3}\b'/'linux_TomCAT ansible_host='$2/g hosts.txt