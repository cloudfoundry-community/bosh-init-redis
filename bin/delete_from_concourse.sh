#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd $DIR/..

export PATH=$PWD/bin:$PATH
export PATH=$PWD/build-bosh-init/gopath/src/github.com/cloudfoundry/bosh-init/out:$PATH

# reuse the fake home from 'deployment' task that's inside the project so it can be accessed by subsequent concourse steps
export HOME=$PWD/tmp/home

bosh-init delete redis.yml
