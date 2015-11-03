#!/bin/bash

if [ $UID != 0 ]; then
	echo "Not enough privileges to run this script"
	exit 1
fi

echo "Updating..."
apt-get update > /dev/null 2>&1
echo "Installing ack..." 2>&1
apt-get install -yf ack-grep > /dev/null 2>&1
echo "Installing ctags..." 2>&1
apt-get install -yf exuberant-ctags > /dev/null 2>&1
echo "Installing fontconfig..."
apt-get install -yf fontconfig > /dev/null
echo "Installing git..."
apt-get install -yf git > /dev/null 2>&1
echo "Installing mercurial..."
apt-get install -yf mercurial > /dev/null 2>&1
echo "Installing xfce4..."
apt-get install -yf xfce4 > /dev/null 2>&1
echo "Installing terminator..."
apt-get install -yf terminator > /dev/null 2>&1
echo "Installing vim..."
apt-get install -yf vim > /dev/null 2>&1

if [ `vim --version | ack '([+]ruby)' | wc -l` -eq 0 ]
then
   echo "Missing ruby support in vim. Recompiling..."
   echo "Removing installed package..."
   apt-get remove -yf vim-common vim-runtime > /dev/null 2>&1
   echo "Installing build dependencies..."
   apt-get build-dep -yf vim > /dev/null 2>&1
   echo "Cloning..."
   hg clone https://vim.googlecode.com/hg/ /tmp/vim > /dev/null 2>&1
   cd /tmp/vim
   echo "Configuring..."
   ./configure --enable-pythoninterp --enable-rubyinterp
   echo "Building"
   make > /dev/null
   echo "Installing"
   make install > /dev/null
   cd -
fi

echo "You can now run the config.sh script, using your normal user"
