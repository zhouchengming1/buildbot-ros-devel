#! /bin/bash

# APT repo hold pkgs of different distros
# Should sign every pkg when included (write by current user)
# Now, we don't sign the pkg

# Everybody can apt-get the repo: no ftp passwd or ssh key
# Then exported by nginx (read by www user)

# create the apt repo

sudo apt-get install -y reprepro
sudo apt-get install -y dpkg-sig

name=cainiao
distro=xenial
# arch, distros, main component
./aptrepo-create.bash $name "amd64 i386" $distro


# upload file: incoming dir
REPO_DIR=$HOME/www/packages
INCOMING=$REPO_DIR/incoming
mkdir -p $INCOMING
# ssh key used for upload file and remote command exec
cp ~/.ssh/id_rsa.pub $REPO_DIR/ssh.key
# don't use ftp anymore, just use Nginx upload module
#sudo apt-get install -y vsftpd
#sudo mv /etc/vsftpd.conf /etc/vsftpd.conf.orig
#sudo cp ftp.conf /etc/vsftpd.conf 
#sudo /etc/init.d/vsftpd restart


# vhost use the repo_dir
# /home/buildbot/www/packages
sudo apt-get install -y nginx
sudo cp vhost /etc/nginx/sites-available/apt.example.com.vhost
sudo ln -s /etc/nginx/sites-available/apt.example.com.vhost /etc/nginx/sites-enabled/
sudo /etc/init.d/nginx reload

# add www-data to buildbot group, so can write incoming dir
# incoming: 755
sudo usermod -a -G buildbot www-data

