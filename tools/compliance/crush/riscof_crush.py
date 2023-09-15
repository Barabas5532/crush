import os
import re
import shutil
import subprocess
import shlex
import logging
import random
import string
from string import Template
import sys
import yaml

import riscof.utils as utils
import riscof.constants as constants
from riscof.pluginTemplate import pluginTemplate

logger = logging.getLogger()

class crush(pluginTemplate):
    __model__ = "crush"
    __version__ = ""

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

        config = kwargs['config']

        with open('../../crush.core') as f:
            core = yaml.load(f)

        core_name = core['name']
        self.version = core_name.split(':')[-1]

        self.dut_exe = '../../build/crush_{version}/sim_cpu-icarus/crush_{version}'

        cwd = os.getcwd()
        logger.debug(f'Current working directory: {cwd}')

        self.isa_spec = os.path.join(cwd, 'crush/crush_isa.yaml')
        self.platform_spec = os.path.abspath(cwd, 'crush/crush_platform.yaml')

    def initialise(self, suite, work_dir, archtest_env):
        self.working_directory = working_directory

    def build(self, isa_yaml, platform_yaml):
        build_cmd = 'fusesoc run --target sim_cpu --build crush'
        logger.debug(f'Build simulator: {build_cmd}')
        utils.shellCommand(build_cmd).run(cwd=self.working_directory)

    def runTests(self, test_list):
        # we will iterate over each entry in the testList. Each entry node will
        # be referred to by the variable testname.
        for test_name in testList:
            logger.debug(f'Running Test: {test_name} on DUT')

            test_entry = test_list[testname]
            test_source_path = test_entry['test_path']
            working_directory = test_entry['work_dir']

            # name of the signature file as per requirement of RISCOF. RISCOF
            # expects the signature to be named as DUT-<dut-name>.signature. The
            # below variable creates an absolute path of signature file.
            sig_file = os.path.join(test_dir, self.name[:-1] + ".signature")

            compile_macros= ' -D' + " -D".join(testentry['macros'])

            logger.debug('Compiling test: {test_source_path}')
            # cmd = ('riscv32-unknown-elf-gcc '
            #         '-march=rv32i '
            #         '-mabi=ilp32 '
            #         '-static '
            #         '-mcmodel=medany '
            #         '-fvisibility=hidden '
            #         '-nostdlib '
            #         '-nostartfiles '
            #         '-g '
            #         '-T crush/env/link.ld '
            #         '-I crush/env/ '
            #         '-I {archtest_env} '
            #         f'{compile_macros} '
            #         '-o test.elf ' +
            #         test_source_path
            #       )
            utils.shellCommand(cmd).run(cwd=working_directory)

            binary_path = os.path.join(working_directory, 'test.bin')
            binary_cmd = 'riscv64-unknown-elf-objdump -O binary test.elf {binary_path}'
            logger.debug('Convert to binary: ' + binary_cmd)
            utils.shellCommand(binary_cmd).run(cwd=working_directory)

            sim_cmd = f'vvp {self.dut_exe} +SIGNATURE_PATH={sig_file} +BINARY_PATH={binary_path}'
            logger.debug('Executing simulator' + sim_cmd)
            utils.shellCommand(sim_cmd).run(cwd=working_directory)
