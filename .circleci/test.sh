#!/usr/bin/env bash

set -ex

mkdir /tmp/cnl
cd /tmp/cnl

apt-get update
apt-get install --quiet --yes libboost-dev

conan remote add \
  johnmcfarlane/cnl https://api.bintray.com/conan/johnmcfarlane/cnl

/root/project/test/scripts/unit-test.sh \
  -DCMAKE_TOOLCHAIN_FILE=/root/project/test/cmake/toolchain/gcc.cmake \
  -G "Unix Makefiles"
