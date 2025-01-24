#!/usr/bin/env bash

export YOSYS_DATDIR=$(yosys-config --datdir)

rm -rf fusesoc_libraries
fusesoc library add --sync-type local crush crush
fusesoc library add --sync-type local crush_example crush_example
fusesoc library add --sync-type local crush_example_freertos crush_example_freertos
fusesoc library add --sync-type local crush_support support
fusesoc library add fusesoc_cores https://github.com/fusesoc/fusesoc-cores
