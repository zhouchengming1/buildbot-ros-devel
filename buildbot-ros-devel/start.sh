#! /bin/bash

cd master

buildbot create-master
buildbot start

cd ..

# worker dir
buildbot-worker create-worker worker localhost example-worker pass
cd worker
buildbot-worker start

