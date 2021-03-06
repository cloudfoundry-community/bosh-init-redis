#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd $DIR/..

if [[
"${EIP}X" == "X" ||
"${ACCESS_KEY_ID}X" == "X" ||
"${SECRET_ACCESS_KEY}X" == "X" ||
"${KEY_NAME}X" == "X" ||
"${PRIVATE_KEY_PATH}X" == "X" ||
"${SECURITY_GROUP}X" == "X" ]]; then
  echo "USAGE: EIP=xxx ACCESS_KEY_ID=xxx SECRET_ACCESS_KEY=xxx KEY_NAME=xxx PRIVATE_KEY_PATH=xxx SECURITY_GROUP=xxx ./bin/make_manifest.sh"
  exit 1
fi

stemcell_path=stemcell/stemcell.tgz
aws_cpi_release_path=release-cpi/release.tgz
redis_release_path=release-redis/release.tgz

cat >redis.yml <<EOF
---
name: redis

releases:
- name: bosh-aws-cpi
  url: file://${aws_cpi_release_path}
- name: redis
  url: file://${redis_release_path}

resource_pools:
- name: default
  network: default
  stemcell:
    url: file://${stemcell_path}
  cloud_properties:
    instance_type: m3.medium
    availability_zone: us-east-1c

jobs:
- name: redis
  instances: 1
  persistent_disk: 10240
  resource_pool: default
  templates:
  - {name: redis, release: redis}
  networks:
  - name: vip
    static_ips: [$EIP]
  - name: default

  properties:
    redis:
      port: 6379

networks:
- name: default
  type: dynamic
- name: vip
  type: vip

cloud_provider:
  template: {name: cpi, release: bosh-aws-cpi}

  ssh_tunnel:
    host: $EIP
    port: 22
    user: vcap
    private_key: $PRIVATE_KEY_PATH

  registry: &registry
    username: admin
    password: admin
    port: 6901
    host: localhost

  # Tells bosh-micro how to contact remote agent
  mbus: https://nats:nats@$EIP:6868

  properties:
    aws:
      access_key_id: $ACCESS_KEY_ID
      secret_access_key: $SECRET_ACCESS_KEY
      default_key_name: $KEY_NAME
      default_security_groups: [$SECURITY_GROUP]
      region: us-east-1

    # Tells CPI how agent should listen for requests
    agent: {mbus: "https://nats:nats@0.0.0.0:6868"}

    registry: *registry

    blobstore:
      provider: local
      path: /var/vcap/micro_bosh/data/cache

    ntp: [0.north-america.pool.ntp.org]
EOF
