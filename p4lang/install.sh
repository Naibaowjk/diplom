#!/bin/bash

# Print script commands and exit on errors.
set -xe

# Prepare
FILE1=~/applications
if [ ! -d "$FILE1" ]; then
    mkdir ~/applications
fi
FILE2=~/downloads
if [ ! -d "$FILE2" ]; then
    mkdir ~/downloads
fi
FILE3=~/.local
if [ ! -d "$FILE3" ]; then
    mkdir ~/.local
fi
cd  ~/downloads
FILE1=tutorials
if [ -d "$FILE1" ]; then
    sudo rm -rf $FILE1
fi
FILE1=mininet
if [ -d "$FILE1" ]; then
    sudo rm -rf $FILE1
fi
FILE1=protobuf
if [ -d "$FILE1" ]; then
    sudo rm -rf $FILE1
fi
FILE1=gRPC
if [ -d "$FILE1" ]; then
    sudo rm -rf $FILE1
fi
sudo rm -rf PI 
FILE1=PI
if [ -d "$FILE1" ]; then
    sudo rm -rf $FILE1
fi
FILE1=behavioral-model
if [ -d "$FILE1" ]; then
    sudo rm -rf $FILE1
fi
FILE1=p4c
if [ -d "$FILE1" ]; then
    sudo rm -rf $FILE1
fi
FILE1=ptf
if [ -d "$FILE1" ]; then
    sudo rm -rf $FILE1
fi
git clone https://github.com/p4lang/tutorials.git
export PATCH_DIR=~/downloads/tutorials/vm-ubuntu-20.04/patches


# --- Mininet --- #
export MININET_COMMIT="aa0176fce6fb718a03474f8719261b07b670d30d"  # 2022-Apr-02
git clone https://github.com/mininet/mininet mininet
cd mininet
git checkout ${MININET_COMMIT}
patch -p1 < "${PATCH_DIR}/mininet-dont-install-python2-2022-apr.patch" || echo "Errors while attempting to patch mininet, but continuing anyway ..."
cd ..
sudo ./mininet/util/install.sh -nw # In Ubuntu 22.04, pylint3 package can't locale, so I personally delete pylint3 package and install it by pip3.

sudo find /usr/lib /usr/local $HOME/.local | sort > $HOME/usr-local-7-after-mininet-install.txt

# --- Emacs --- #
sudo cp $HOME/downloads/tutorials/vm-ubuntu-20.04/p4_16-mode.el /usr/share/emacs/site-lisp/
mkdir $HOME/.emacs.d/
echo "(autoload 'p4_16-mode' \"p4_16-mode.el\" \"P4 Syntax.\" t)" > init.el
echo "(add-to-list 'auto-mode-alist '(\"\\.p4\\'\" . p4_16-mode))" | tee -a init.el
mv init.el $HOME/.emacs.d/
sudo ln -s /usr/share/emacs/site-lisp/p4_16-mode.el $HOME/.emacs.d/p4_16-mode.el

# --- Dev-bootstrap --- #
BMV2_COMMIT="f16d0de3486aa7fb2e1fe554aac7d237cc1adc33"  # 2022-May-01
PI_COMMIT="f547455a260b710706bef82afab4cb9937bac416"    # 2022-May-01
P4C_COMMIT="1471fdd22b683e1946b7730d83c877d94daba683"   # 2022-May-01
PTF_COMMIT="405513bcad2eae3092b0ac4ceb31e8dec5e32311"   # 2022-May-01
PROTOBUF_COMMIT="v3.6.1"
GRPC_COMMIT="tags/v1.17.2"

# Get the number of cores to speed up the compilation process
NUM_CORES=`grep -c ^processor /proc/cpuinfo`

# Maybe we should install python package in dist-packages, but at now we ignore it, because I use conda.
sudo find /usr/lib /usr/local $HOME/.local | sort > $HOME/usr-local-1-before-protobuf.txt
git clone https://github.com/google/protobuf.git
cd protobuf
git checkout ${PROTOBUF_COMMIT}
sudo apt-get install autoconf automake libtool
./autogen.sh
# install-p4dev-v4.sh script doesn't have --prefix=/usr option here.
./configure --prefix=/usr
make -j${NUM_CORES}
sudo make install
sudo ldconfig
cd ..

sudo find /usr/lib /usr/local $HOME/.local | sort > $HOME/usr-local-2-after-protobuf.txt

# --- gRPC --- #
git clone https://github.com/grpc/grpc.git
cd grpc
git checkout ${GRPC_COMMIT}
git submodule update --init --recursive
# Apply patch that seems to be necessary in order for grpc v1.17.2 to
# compile and install successfully on an Ubuntu 19.10 and later
# system.
patch -p1 < "${PATCH_DIR}/disable-Wno-error-and-other-small-changes.diff" || echo "Errors while attempting to patch grpc, but continuing anyway ..."
make -j${NUM_CORES}
sudo make install
# I believe the following 2 commands, adapted from similar commands in
# src/python/grpcio/README.rst, should install the Python3 module
# grpc.

sudo find /usr/lib /usr/local $HOME/.local | sort > $HOME/usr-local-2b-before-grpc-pip3.txt
pip3 list | tee $HOME/pip3-list-2b-before-grpc-pip3.txt
pip3 install -r requirements.txt # cython-0.29.33
GRPC_PYTHON_BUILD_WITH_CYTHON=1 pip3 install .
sudo ldconfig
cd ..

sudo find /usr/lib /usr/local $HOME/.local | sort > $HOME/usr-local-3-after-grpc.txt

# --- PI/P4Runtime --- #
git clone https://github.com/p4lang/PI.git
cd PI
git checkout ${PI_COMMIT}
git submodule update --init --recursive
./autogen.sh
# install-p4dev-v4.sh adds more --without-* options to the configure
# script here.  I suppose without those, this script will cause
# building PI code to include more features?
sudo apt-get install pkg-config libboost-all-dev
./configure --with-proto
make -j${NUM_CORES}
sudo make install
# install-p4dev-v4.sh at this point does these things, which might be
# useful in this script, too:
# Save about 0.25G of storage by cleaning up PI build
make clean
# move_usr_local_lib_python3_from_site_packages_to_dist_packages
sudo ldconfig
cd ..

sudo find /usr/lib /usr/local $HOME/.local | sort > $HOME/usr-local-4-after-PI.txt

# --- Bmv2 --- #
git clone https://github.com/p4lang/behavioral-model.git
cd behavioral-model
git checkout ${BMV2_COMMIT}
./install_deps.sh
./autogen.sh
./configure --enable-debugger --with-pi --with-thrift
make -j${NUM_CORES}
sudo make install-strip
sudo ldconfig
# install-p4dev-v4.sh script does this here:
# move_usr_local_lib_python3_from_site_packages_to_dist_packages
cd ..

sudo find /usr/lib /usr/local $HOME/.local | sort > $HOME/usr-local-5-after-behavioral-model.txt

# --- P4C --- #
git clone https://github.com/p4lang/p4c
cd p4c
git checkout ${P4C_COMMIT}
git submodule update --init --recursive
mkdir -p build
cd build
sudo apt-get install libgc-dev
cmake ..
# The command 'make -j${NUM_CORES}' works fine for the others, but
# with 2 GB of RAM for the VM, there are parts of the p4c build where
# running 2 simultaneous C++ compiler runs requires more than that
# much memory.  Things work better by running at most one C++ compilation
# process at a time.
make -j1
sudo make install
sudo ldconfig
cd ../..

find /usr/lib /usr/local $HOME/.local | sort > $HOME/usr-local-6-after-p4c.txt

# --- PTF --- #
git clone https://github.com/p4lang/ptf
cd ptf
git checkout ${PTF_COMMIT}
python3 setup.py install
cd ..

find /usr/lib /usr/local $HOME/.local | sort > $HOME/usr-local-8-after-ptf-install.txt

# reboot
sudo reboot