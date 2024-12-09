#!/usr/bin/env bash

export YOSYS_DATDIR=$(yosys-config --datdir)

rm -rf fusesoc_libraries
fusesoc library add --sync-type local crush .
fusesoc library add fusesoc_cores https://github.com/fusesoc/fusesoc-cores
