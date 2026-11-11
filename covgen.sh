#!/usr/bin/env sh

set -ex

mkdir -p ./coverage
lcov -c -d ./src -o coverage/lcov.info.all
lcov --ignore-errors unused -r coverage/lcov.info.all '*/include/*' -o coverage/lcov.info
