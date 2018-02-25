#!/bin/sh

# this daemon run as buildbot user in ~/www/packages/incoming/
# so we should add buildbot to adm group
# then we can read this log file

# sudo usermod -a -G adm buildbot
# You should relogin

# And we can run these shell scripts as buildbot user

# How to run this script as daemon:
# nohup check-incoming-daemon.bash 0<&- &> my.admin.log.file &

ACCESS_LOG=/var/log/nginx/packages-error.log

check_string="PUT /incoming/ros-kinetic-"

# 42.120.74.231 - - [05/Mar/2018:09:28:02 +0800] "PUT /incoming/ros-kinetic-um6_0.0.1-0xenial_amd64.deb HTTP/1.1" 201 25 "-" "curl/7.47.0"

tail -F -n 1 $ACCESS_LOG | while read line; do

	if echo "$line" | grep -q "$check_string"; then
		#filename=$(echo "$line" | cut -d, -f2)
		#if [ -s "$filename" ]; then
			# do something with $filename
		#fi
		server-repo-include.bash
	fi
done

