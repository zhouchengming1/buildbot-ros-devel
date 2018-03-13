#! /bin/bash

sudo apt-get install -y git-buildpackage || exit 1
sudo apt-get install -y pbuilder cowbuilder || exit 1
sudo apt-get install -y fakeroot || exit 1
sudo apt-get install -y dpkg-dev debhelper || exit 1

# + local apt repo in /var/cache/pbuilder/result
# the hook will scan all debs in there and apt-get update
sudo mkdir -p /var/cache/pbuilder/hooks || exit 1
sudo mkdir -p /var/cache/pbuilder/result || exit 1
sudo cp hooks/D70results /var/cache/pbuilder/hooks/ || exit 1
rm ~/.pbuilderrc
echo 'AUTO_DEBSIGN=${AUTO_DEBSIGN:-no}' >> ~/.pbuilderrc
echo 'HOOKDIR=/var/cache/pbuilder/hooks' >> ~/.pbuilderrc
echo 'BINDMOUNTS="/var/cache/pbuilder/result"' >> ~/.pbuilderrc
sudo chmod 777 /var/cache/pbuilder/result

# Need sudo without password: auto, You should set sudoers at the begining
# visudo:
# buildbot	ALL= NOPASSWD: SETENV: /usr/bin/gbp, /usr/bin/git-*, /usr/sbin/*builder
./cowbuilder-update.py xenial amd64 || exit 1
