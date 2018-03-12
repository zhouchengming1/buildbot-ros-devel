#! /bin/bash

# catkin: package topology
# rosdep: check/install project depends
# bloom: create release repo

sudo apt-get install -y python-rosdep
sudo apt-get install -y pip
sudo pip install -U pip
sudo pip install -U catkin
sudo pip install -U catkin_pkg
sudo pip install -U bloom

# tools for ros build
sudo apt-get install -y python-rosinstall python-rosinstall-generator python-wstool build-essential

url=apt.xiaog.xyz
port=4500
distro=xenial
component=main

sudo rosdep init || exit 1
sudo rm /etc/ros/rosdep/sources.list.d/20-default.list
echo "yaml http://${url}:${port}/private.yaml" | sudo tee /etc/ros/rosdep/sources.list.d/10-private.list > /dev/null
# and replace official, it's too slow
echo "yaml http://${url}:${port}/base.yaml" | sudo tee --append /etc/ros/rosdep/sources.list.d/20-default.list > /dev/null
echo "yaml http://${url}:${port}/python.yaml" | sudo tee --append /etc/ros/rosdep/sources.list.d/20-default.list > /dev/null
echo "yaml http://${url}:${port}/ruby.yaml" | sudo tee --append /etc/ros/rosdep/sources.list.d/20-default.list > /dev/null
if ! grep "ROSDISTRO_INDEX_URL" ~/.bashrc; then
echo "export ROSDISTRO_INDEX_URL=http://${url}:$port/index.yaml" >> ~/.bashrc
# this source is useless when the script exit
source ~/.bashrc
fi
export ROSDISTRO_INDEX_URL=http://${url}:$port/index.yaml
# we may use this local keys mapping later
echo | sudo tee /etc/ros/rosdep/sources.list.d/30-local.list > /dev/null
rosdep update || exit 1

# private ros pkgs
echo "deb http://${url}:$port $distro $component" | sudo tee /etc/apt/sources.list.d/ros-private.list > /dev/null
wget -O - -q http://${url}:${port}/apt.key | sudo apt-key add -
sudo -E apt-get update -o Dir::Etc::sourcelist=/etc/apt/sources.list.d/ros-private.list || exit 1

# official ros pkgs
sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116
sudo apt-get update || exit 1

