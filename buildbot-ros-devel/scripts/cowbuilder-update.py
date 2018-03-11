#!/usr/bin/env python

# This is used to setup the cowbuilder

from __future__ import print_function
import sys
import os
import subprocess
import time

# A bit hacky, but do this rather than redefine the function.
# Has to be in testbuild, as we only copy testbuild to pbuilder.
#from testbuild import call

import random
file_num = random.randrange(100000)

## @brief Call a command
## @param command Should be a list
def call(command, envir=None, verbose=True, return_output=False):
    print('Executing command "%s"' % ' '.join(command))
    helper = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, close_fds=True, env=envir)
    if return_output:
        res = ''
    while True:
        output = helper.stdout.readline().decode('utf8', 'replace')
        if helper.returncode is not None or not output:
            break
        if verbose:
            try:
                sys.stdout.write(output)
            except UnicodeEncodeError:
                output = "lost some output, unable to encode in utf-8"
                sys.stdout.write(output)
        if return_output:
            res += output

    helper.wait()
    if helper.returncode != 0:
        msg = 'Failed to execute command "%s" with return code %d' % (command, helper.returncode)
        print('/!\  %s' % msg)
        raise BuildException(msg)
    if return_output:
        return res

## @brief Returns whether we could lock the file
def get_lock(distro, arch):
    global file_num
    if os.path.isfile('/tmp/buildbot_'+distro+'_'+arch+'_lock'):
        # check if our file_num is in the file
        try:
            with open('/tmp/buildbot_'+distro+'_'+arch+'_lock') as f:
                value = int(f.read().rstrip())
                if value == file_num:
                    return True
                else:
                    # somebody already has a lock
                    return False
        except:
            return False
    else:
        # try to put our file_num in the lock file:
        with open('/tmp/buildbot_'+distro+'_'+arch+'_lock', 'w') as f:
            f.write(str(file_num))
        # wait a moment
        time.sleep(0.05)
        # check that we got the lock
        return get_lock(distro, arch)

def release_lock(distro, arch):
    if os.path.isfile('/tmp/buildbot_'+distro+'_'+arch+'_lock'):
        # check if our file_num is in the file
        try:
            with open('/tmp/buildbot_'+distro+'_'+arch+'_lock') as f:
                value = int(f.read().rstrip())
                if value == file_num:
                    os.remove('/tmp/buildbot_'+distro+'_'+arch+'_lock')
                    return True
                else:
                    # somebody already has a lock
                    return False
        except:
            return False
    return False

## @brief Returns the basepath of the cowbuilder
## @param distro The UBUNTU distribution (for instance, 'precise')
## @param arch The architecture (for instance, 'amd64')
def basepath(distro, arch):
    return '/var/cache/pbuilder/base-'+distro+'-'+arch+'.cow'

def defaultmirrors(distro, arch):
    # cowdancer is in universe?
    if (arch == "amd64" or arch == "i386"):
        # use ubuntu archive for x86 or x64 cowbuilders
        return "deb http://archive.ubuntu.com/ubuntu DISTRO main universe".replace('DISTRO', distro)
    else:
        # use ubuntu ports for other cowbuilders (such as arm)
        return "deb http://ports.ubuntu.com/ubuntu-ports DISTRO main universe".replace('DISTRO', distro)

def getKeyCommands(keys):
    if len(keys) == 0:
        return ""
    return '\n'.join(['wget '+key+' -O- | apt-key add -' for key in keys])+'\n'

## @brief Make a cowbuilder, if one does not exist
## @param distro The UBUNTU distribution (for instance, 'precise')
## @param arch The architecture (for instance, 'amd64')
## @param keys List of keys to get
def make_cowbuilder(distro, arch, keys):
    print('(' + str(time.time()) +')Getting lock on cowbuilder')
    while not get_lock(distro, arch):
        time.sleep(1.0)
    print('(' + str(time.time()) +')Got lock!')
    if not os.path.exists(basepath(distro, arch)):
        # create the cowbuilder
        call(['sudo', 'cowbuilder', '--create',
              '--distribution', distro,
              '--architecture', arch,
              '--debootstrapopts', '--arch',
              '--debootstrapopts', arch,
              '--basepath', basepath(distro, arch),
              '--othermirror', defaultmirrors(distro, arch)])
    else:
        print('cowbuilder already exists for %s-%s' % (distro, arch))

    # login and install wget (for later adding keys)
    command = ['sudo', 'cowbuilder', '--login',
               '--save-after-login',
               '--distribution', distro,
               '--architecture', arch,
               '--basepath', basepath(distro, arch)]
               #'--othermirror', defaultmirrors(distro)]
    print('Executing command "%s"' % ' '.join(command))
    cowbuilder = subprocess.Popen(command, stdout=subprocess.PIPE, stdin=subprocess.PIPE, stderr=subprocess.STDOUT)
    output = cowbuilder.communicate(input="""echo "Installing python"
apt-get install python -y
echo "Installing wget"
apt-get install wget -y
apt-get install lsb-release -y
"""+getKeyCommands(keys)+"""echo "setup official rosdistro"
apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116
echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list
"""+"""echo "setup private rosdistro"
wget -O - -q http://apt.xiaog.xyz:4500/apt.key | apt-key add -
echo "deb http://apt.xiaog.xyz:4500 xenial main" > /etc/apt/sources.list.d/ros-private.list
"""+"""echo "exiting"
exit
""")
    print(output[0])
    if cowbuilder.returncode != 0:
        exit(cowbuilder.returncode)

    # update
    print('updating cowbuilder')
    call(['sudo', 'cowbuilder', '--update',
          '--distribution', distro,
          '--architecture', arch,
          '--basepath', basepath(distro, arch)])

if __name__=="__main__":
    if len(sys.argv) < 3:
        print('')
        print('Usage: cowbuilder.py <distro> <arch>')
        print('')
        exit(-1)
    distro = sys.argv[1]
    arch = sys.argv[2]
    try:
        if len(sys.argv) > 3:
            make_cowbuilder(distro, arch, sys.argv[3:])
        else:
            make_cowbuilder(distro, arch, [])
    finally:
        release_lock(distro, arch)
