#!/usr/bin/env bash
printf "00100093\n9300F0FF" | ./riscv-filter.py
