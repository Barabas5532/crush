#!/usr/bin/env bash

set -eo pipefail

cd tools/compliance

if [ -z "${CI}" ]; then
   config=config.ini
else
   config=config-ci.ini
fi

riscof run --config=$config --suite=riscv-arch-test/riscv-test-suite/ --env=riscv-arch-test/riscv-test-suite/env
