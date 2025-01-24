#!/usr/bin/env bash

export YOSYS_DATDIR=$(yosys-config --datdir)

rm -f fusesoc.conf
rm -rf fusesoc_libraries
fusesoc library add --sync-type local crush crush
fusesoc library add --sync-type local crush_example crush_example
fusesoc library add --sync-type local crush_example_freertos crush_example_freertos
fusesoc library add --sync-type local crush_testing crush_testing
fusesoc library add --sync-type local crush_util crush_util
fusesoc library add fusesoc_cores https://github.com/fusesoc/fusesoc-cores
