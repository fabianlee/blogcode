#!/bin/bash

sudo apt update
sudo apt update sudo apt install -y curl gpg g++ gcc autoconf automake bison libc6-dev libffi-dev libgdbm-dev libncurses5-dev libsqlite3-dev libtool libyaml-dev make pkg-config sqlite3 zlib1g-dev libgmp-dev libreadline-dev libssl-dev

# install GPG keys to packages
curl -sSL https://rvm.io/mpapis.asc | gpg --import -
curl -sSL https://rvm.io/pkuczynski.asc | gpg --import -

# install rvm and source the env
curl -sSL https://get.rvm.io | bash -s stable
source ~/.rvm/scripts/rvm

# use rvm to install ruby and set default ruby 3.x
rvm install ruby-3.1.0
rvm --default use ruby-3.1.0

# check versions (should be 3.1.x+)
ruby --version
gem --version

# install jekyll
gem install jekyll
jekyll --version
