#!/usr/bin/env python3
import sys
import time

def main():
    fh_in = sys.stdin
    fh_out = sys.stdout

    while True:
        l = fh_in.readline()
        if not l:
            return 0

        time.sleep(1)
        fh_out.write(f"sleepy {l}")
        fh_out.flush()


if __name__ == '__main__':
	sys.exit(main())
