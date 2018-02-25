#! /bin/bash

cd master

buildbot stop

cd ..

cd worker

buildbot-worker stop
