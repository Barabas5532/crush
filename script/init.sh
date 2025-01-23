#!/usr/bin/env bash

export YOSYS_DATDIR=$(yosys-config --datdir)
fusesoc library add --sync-type local crush crush
fusesoc library add --sync-type local crush_example crush_example
