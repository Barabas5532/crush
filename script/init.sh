#!/usr/bin/env bash

set -eo pipefail

fusesoc library add --sync-type local crush .
