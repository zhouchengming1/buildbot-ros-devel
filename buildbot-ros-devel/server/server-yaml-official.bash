#! /bin/bash

REPO_DIR=$HOME/www/packages

# private keys
touch $REPO_DIR/private.yaml

# generic
wget https://raw.githubusercontent.com/ros/rosdistro/master/rosdep/base.yaml -q -O $REPO_DIR/base.yaml
wget https://raw.githubusercontent.com/ros/rosdistro/master/rosdep/python.yaml -q -O $REPO_DIR/python.yaml
wget https://raw.githubusercontent.com/ros/rosdistro/master/rosdep/ruby.yaml -q -O $REPO_DIR/ruby.yaml
wget https://raw.githubusercontent.com/ros/rosdistro/master/index.yaml -q -O $REPO_DIR/index.yaml

# index include kinetic
mkdir -p $REPO_DIR/kinetic
wget https://raw.githubusercontent.com/ros/rosdistro/master/kinetic/distribution.yaml -q -O $REPO_DIR/kinetic/distribution.yaml

# then you should modify the index file to custom kinetic
# And only need kinetic

