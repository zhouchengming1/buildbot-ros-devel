#! /bin/bash

# private ros pkgs
wget -O - -q http://${url}:${port}/apt.key | sudo apt-key add -
echo "deb http://${url}:$port $distro $component" | sudo tee /etc/apt/sources.list.d/ros-private.list > /dev/null
sudo -E apt-get update -o Dir::Etc::sourcelist=/etc/apt/sources.list.d/ros-private.list

# official ros pkgs
sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116
sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
sudo apt-get update
