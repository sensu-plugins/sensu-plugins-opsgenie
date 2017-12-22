#!/bin/bash
set -e

apt-get install software-properties-common
apt-add-repository -y ppa:brightbox/ruby-ng
apt-get update
apt-get install -y build-essential
apt-get install -y ruby2.4 ruby2.4-dev

source /etc/profile
DATA_DIR=/tmp/kitchen/data

cd $DATA_DIR
SIGN_GEM=false gem build sensu-plugins-opsgenie.gemspec
gem install sensu-plugins-opsgenie-*.gem
