#! /bin/bash

# exec by nginx user after PUT
# and can write in incoming dir

# Or exec by buildbot user,
# check the incoming dir periodically

# to
REPO_DIR=/home/buildbot/www/packages
yaml_file=$REPO_DIR/private.yaml
# from
INCOMING=$REPO_DIR/incoming

#
# Make sure we're in the apt/ directory
#
cd $INCOMING

deb_dir=$(mktemp -d -p .)

if ! mv *.deb $deb_dir; then
	rm -rf $deb_dir
	exit -1
fi

cd $deb_dir
# these pkgs owned by nginx, so we should use sudo to chown first
#-rw------- 1 www-data www-data 4480 Mar  5 11:57 ros-kinetic-um6_3.0.1-0xenial_amd64.deb
# so we should use "sudo -E visudo" to allow buildbot user to exec some command(with sudo)
sudo chown buildbot:buildbot *
ls -l

for i in *.deb; do

	package=$(dpkg --info $i | grep "Package:" | cut -d " " -f 3)
	version=$(dpkg --info $i | grep "Version:" | cut -d " " -f 3)

if [[ -n $package ]]; then
	# Skipping inclusion of 'ros-kinetic-um6' '0.0.1-0xenial' in 'xenial|main|amd64', as it has already '0.0.2-0xenial'.
	# Only higher version will includedeb suceess, but we can remove it first to support rollback

	# check if this package already here
	#if reprepro -b $REPO_DIR list xenial $package | grep $version; then

	#if reprepro -b $REPO_DIR list xenial $package | grep $package; then
	#	reprepro -b $REPO_DIR remove xenial $package
	#fi

	# At last, we don't support rollback or replace
	# Users may have installed the newest version, rollback will break user's env...
	# So includedeb may fail

	# xenial:main
	reprepro -V -b $REPO_DIR -C main includedeb xenial $i

	ros_pkg=${package#ros-kinetic-}
	echo $ros_pkg
	# underscore
	ros_pkg2=$(echo $ros_pkg | sed 's/-/_/g')

	# if private pkg has been added in private keys
	# Although we needn't to install apt packages
	# So we needn't to update apt-get database
	# But we need to update the new rosdep keys map
	update_rosdep=false
	if ! rosdep resolve $ros_pkg; then
	echo "${ros_pkg}:" >> $yaml_file
	echo "  ubuntu: $package" >> $yaml_file
	echo "  fedora: $package" >> $yaml_file
	echo >> $yaml_file
	update_rosdep=true
	fi
	if ! rosdep resolve $ros_pkg2; then
	echo "${ros_pkg2}:" >> $yaml_file
	echo "  ubuntu: $package" >> $yaml_file
	echo "  fedora: $package" >> $yaml_file
	echo >> $yaml_file
	update_rosdep=true
	fi
	$update_rosdep && rosdep update
fi

done

cd ..
rm -rf $deb_dir

