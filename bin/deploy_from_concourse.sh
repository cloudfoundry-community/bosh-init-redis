#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd $DIR/..

export PATH=$PWD/bin:$PATH
export PATH=$PWD/build-bosh-init/gopath/src/github.com/cloudfoundry/bosh-init/out:$PATH

bosh-init deploy redis.yml \
  stemcell/stemcell.tgz \
  release-aws-cpi/release.tgz \
  release-redis/release.tgz
