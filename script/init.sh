#!/usr/bin/env bash

set -eo pipefail

export YOSYS_DATDIR=$(yosys-config --datdir)
fusesoc library add --sync-type local crush .
