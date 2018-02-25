#! /bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# master and worker run in the virtualenv
sudo apt-get install -y python-virtualenv python-dev

# worker will use catkin and bloom to create debian layout

# package bloom debian layout
sudo apt-get install -y fakeroot
sudo apt-get install -y dpkg-dev debhelper

if ! [[ -d sandbox/bin ]]; then
virtualenv --no-site-packages sandbox
#echo "export PATH=$DIR/scripts:${PATH}" >> sandbox/bin/activate
echo "_DIR=$DIR" >> sandbox/bin/activate
echo 'export PATH=$_DIR/scripts:${PATH}' >> sandbox/bin/activate
fi

# local developer also need these scripts
if ! grep "_DIR" ~/.bashrc; then
echo "_DIR=$DIR" >> ~/.bashrc
echo 'export PATH=$_DIR/scripts:${PATH}' >> ~/.bashrc
# this source is useless when the script exit
source ~/.bashrc
fi

# prepare ROS env
sudo apt-get install -y pip
sudo pip install -U pip

# not use python3 rosdep
#sudo pip install -U rosdep
sudo apt-get install -y python-rosdep


if ! [[ -d /opt/ros/kinetic ]]; then
# official ros pkgs
sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116
sudo apt-get update

# Need kinetic ros to build bloom pkg
sudo apt-get install -y ros-kinetic-ros-base
#sudo apt-get install -y ros-kinetic-desktop-full
fi

if ! grep "source /opt/ros/kinetic/setup.bash" ~/.bashrc; then
echo "source /opt/ros/kinetic/setup.bash" >> ~/.bashrc
# this source is useless when the script exit
source ~/.bashrc
fi

# tools for ros build
sudo apt-get install -y python-rosinstall python-rosinstall-generator python-wstool build-essential

# If build pkg B depend on private pkg A
# private ros keys
# private ros pkgs source-list
# added later

url=apt.xiaog.xyz
port=4500
distro=xenial
component=main

# remote release machine
#sudo echo "yaml http://${url}:${port}/private.yaml" > /etc/ros/rosdep/sources.list.d/30-private.list
#sudo echo "deb http://${url}:$port $distro $component" > /etc/apt/sources.list.d/ros-private.list
echo "deb http://${url}:$port $distro $component" | sudo tee /etc/apt/sources.list.d/ros-private.list > /dev/null
# public key to check pkg from the repo
wget -O - -q http://${url}:${port}/apt.key | sudo apt-key add -
# update cache
sudo -E apt-get update -o Dir::Etc::sourcelist=/etc/apt/sources.list.d/ros-private.list


# private yaml
sudo rosdep init
sudo rm /etc/ros/rosdep/sources.list.d/20-default.list
echo "yaml http://${url}:${port}/private.yaml" | sudo tee /etc/ros/rosdep/sources.list.d/10-private.list > /dev/null
# and replace official, it's too slow
echo "yaml http://${url}:${port}/base.yaml" | sudo tee --append /etc/ros/rosdep/sources.list.d/20-default.list > /dev/null
echo "yaml http://${url}:${port}/python.yaml" | sudo tee --append /etc/ros/rosdep/sources.list.d/20-default.list > /dev/null
echo "yaml http://${url}:${port}/ruby.yaml" | sudo tee --append /etc/ros/rosdep/sources.list.d/20-default.list > /dev/null
export ROSDISTRO_INDEX_URL=http://${url}:$port/index.yaml
if ! grep "ROSDISTRO_INDEX_URL" ~/.bashrc; then
echo "export ROSDISTRO_INDEX_URL=http://${url}:$port/index.yaml" >> ~/.bashrc
# this source is useless when the script exit
source ~/.bashrc
fi
# we may use this local keys mapping later
echo | sudo tee /etc/ros/rosdep/sources.list.d/30-local.list > /dev/null
rosdep update

# You should source ~/.bashrc in your current terminal
# So you can source kinetic setup and use rosdep correctly, and extra _DIR/scripts

# upload to remote centeral repo (will update private yaml keys)
# Use ssh key to upload file and exec command
sudo apt-get install -y dupload
wget http://${url}:${port}/ssh.key -O - -q | cat - >> ~/.ssh/authorized_keys
sudo apt-get install -y git-buildpackage
