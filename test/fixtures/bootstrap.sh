#!/bin/bash
set -e

apt-get update
# apt-get install -y build-essential

source /etc/profile
DATA_DIR=/tmp/kitchen/data

cd $DATA_DIR
SIGN_GEM=false gem build sensu-plugins-opsgenie.gemspec
gem install sensu-plugins-opsgenie-*.gem
