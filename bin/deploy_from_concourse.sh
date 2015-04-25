#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd $DIR/..

export PATH=$PWD/bin:$PATH

bosh-init deploy redis.yml \
  stemcell/stemcell.tgz \
  release-aws-cpi/release.tgz \
  release-redis/release.tgz
