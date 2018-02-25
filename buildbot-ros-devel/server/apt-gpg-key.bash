#! /bin/bash

if gpg --list-keys | grep "sub"; then
	echo "key already there"
	exit 0
fi

# create key for signature
sudo apt-get install -y gnupg

sudo apt-get install -y rng-tools
sudo /etc/init.d/rng-tools start
# sudo systemctl start rng-tools

gpg --gen-key

# don't enter passphrase
# Or reprepro include pkg will ask passphrase

