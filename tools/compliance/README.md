# Compliance tests

This folder contains compliance tests implemented using
[RISCOF](https://github.com/riscv-software-src/riscof). To run the tests,
first create a python virtual environment, and install the tools:

```
python -m venv .venv
. .venv/bin/activate
pip install -r requirements.txt
```

Then follow the RISCOF install guide from the "3.4 Install RISCV-GNU Toolchain":
https://riscof.readthedocs.io/en/stable/installation.html#install-riscv-gnu-toolchain.
Skip section "3.6. Create Neccesary Env Files", it has already been done and
the files are committed to the repository.

After installation is complete, the test can by run using the following command:
`riscof run --config=config.ini --suite=riscv-arch-test/riscv-test-suite/ --env=riscv-arch-test/riscv-test-suite/env`.
