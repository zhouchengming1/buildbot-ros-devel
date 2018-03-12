#! /bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# master and worker run in the virtualenv
sudo apt-get install -y python-virtualenv python-dev

if ! [[ -d sandbox/bin ]]; then
virtualenv --no-site-packages sandbox
echo "_DIR=$DIR" >> sandbox/bin/activate
echo 'export PATH=$_DIR/scripts:${PATH}' >> sandbox/bin/activate
fi

