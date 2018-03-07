#! /bin/bash

# master need
pip install --upgrade pip
pip install 'buildbot[bundle]'

# worker need
pip install buildbot-worker
# required for `runtests` build
pip install setuptools-trial

