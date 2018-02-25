#! /bin/bash

if (( $# != 1 )); then
	echo "usage: xxx debfile"
	exit -1
fi

debfile=$1
if ! [[ -f $debfile ]]; then
	echo "debfile $debfile isn't exist"
	exit -1
fi

# make sure it's a debfile
if ! dpkg --info $debfile; then
	echo "$debfile is NOT a debfile ?"
	exit -1
fi

url=apt.xiaog.xyz
port=4500

# url should has / at last
# PUT /incoming/xxx.deb
# Or curl will send "PUT /incoming"
#curl -T $debfile http://${url}:${port}/incoming/
if curl -T $debfile http://${url}:${port}/incoming/$debfile | grep '<html>'; then
	echo "debfile $debfile upload failed"
	exit -1
fi
echo "debfile $debfile upload success"

