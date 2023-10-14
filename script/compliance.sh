#!/usr/bin/env bash

set -eo pipefail

cd tools/compliance
riscof run --config=config.ini --suite=riscv-arch-test/riscv-test-suite/ --env=riscv-arch-test/riscv-test-suite/env
