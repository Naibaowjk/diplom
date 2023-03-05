#!/bin/bash

# Print script commands and exit on errors.
set -xe

# download dpdk
FILE2=~/downloads
if [ ! -d "$FILE2" ]; then
    mkdir ~/downloads;
fi
cd $HOME/downloads
wget http://fast.dpdk.org/rel/dpdk-22.11.1.tar.xz
tar xJf dpdk-22.11.1.tar.xz 
cd dpdk-stable-22.11.1/

# build
sudo apt-get install meson
pip3 install meson ninja pyelftools
meson setup build
cd build

# configure
if [ ! -d "$HOME/applications"]; then
    mkdir $HOME/applications;
fi
if [ ! -d "$HOME/applications/dpdk"]; then
    mkdir $HOME/applications/dpdk;
fi
meson configure -Dbuildtype=debug
meson configure -Dexamples=all
meson configure -Dprefix=$HOME/applications/dpdk

# install
ninja
ninja install
sudo ldconfig

# edit pkg-config-path
echo "export PKG_CONFIG_PATH=/home/lighthouse/applications/dpdk/lib/x86_64-linux-gnu/pkgconfig/" >> ~/.bashrc
source ~/.bashrc

echo "export LD_LIBRARY_PATH=/home/lighthouse/applications/dpdk/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH" | sudo tee -a /etc/profile
