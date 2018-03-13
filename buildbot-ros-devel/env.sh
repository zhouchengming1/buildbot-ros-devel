#! /bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if ! grep "_DIR" ~/.bashrc; then
echo "_DIR=$DIR" >> ~/.bashrc
echo 'export PATH=$_DIR/scripts:${PATH}' >> ~/.bashrc
# this source is useless when the script exit
source ~/.bashrc
fi

! ./cowbuilder-setup.sh && echo "cowbuilder failed" && exit 1
! ./catkin-rosdep-bloom.sh && echo "catkin-rosdep-bloom.sh failed" && exit 1

if ! [[ -d /opt/ros/kinetic ]]; then
echo #sudo apt-get install -y ros-kinetic-ros-base
fi
if ! grep "source /opt/ros/kinetic/setup.bash" ~/.bashrc; then
echo #echo "source /opt/ros/kinetic/setup.bash" >> ~/.bashrc
#source ~/.bashrc
fi

