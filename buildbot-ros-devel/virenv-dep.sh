#! /bin/bash

# master need
pip install --upgrade pip
pip install 'buildbot[bundle]'

# worker need
pip install --upgrade pip
pip install buildbot-worker
# required for `runtests` build
pip install setuptools-trial

# command need
pip install -U catkin
pip install -U catkin_pkg
pip install -U bloom
# package -> bloom layout -> debian pkg

