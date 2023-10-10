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
from multiprocessing import Pool

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
            core = yaml.load(f, Loader=yaml.Loader)

        core_name = core['name']
        logger.info(f'Read fusesoc name: {core_name}')
        version = core_name.split(':')[-1]

        cwd = os.getcwd()
        logger.info(f'Current working directory: {cwd}')

        self.dut_exe = os.path.join(cwd, f'../../build/crush_{version}/sim_cpu-icarus/crush_{version}')

        self.isa_spec = os.path.join(cwd, 'crush/crush_isa.yaml')
        self.platform_spec = os.path.join(cwd, 'crush/crush_platform.yaml')

    def initialise(self, suite, work_dir, archtest_env):
        self.working_directory = work_dir
        self.archtest_env = archtest_env

    def build(self, isa_yaml, platform_yaml):
        build_cmd = 'fusesoc run --target sim_cpu --build crush'
        logger.info(f'Build simulator: {build_cmd}')
        utils.shellCommand(build_cmd).run(cwd=os.path.join(os.getcwd(), '../..'))

    def runTests(self, test_list):
        logger.info(f'Running {len(test_list)} tests in parallel')

        with Pool(len(test_list)) as p:
            p.map(self.doRunTest, [test_list[x] for x in test_list])

    def doRunTest(self, test_entry):
        test_source_path = test_entry['test_path']
        working_directory = test_entry['work_dir']

        # name of the signature file as per requirement of RISCOF. RISCOF
        # expects the signature to be named as DUT-<dut-name>.signature. The
        # below variable creates an absolute path of signature file.
        sig_file = os.path.join(working_directory, self.name[:-1] + ".signature")

        compile_macros = ' -D' + " -D".join(test_entry['macros'])

        cmd = ('riscv32-unknown-elf-gcc '
                '-march=rv32i '
                '-mabi=ilp32 '
                '-static '
                '-mcmodel=medany '
                '-fvisibility=hidden '
                '-nostdlib '
                '-nostartfiles '
                '-g '
                f'-T {os.path.join(os.getcwd(), "crush/env/link.ld")} '
                f'-I {os.path.join(os.getcwd(), "crush/env/")} '
                f'-I {self.archtest_env} '
                f'{compile_macros} '
                '-o test.elf ' +
                test_source_path
              )
        utils.shellCommand(cmd).run(cwd=working_directory)

        binary_path = os.path.join(working_directory, 'test.bin')
        binary_cmd = f'riscv32-unknown-elf-objcopy -O binary test.elf {binary_path}'
        utils.shellCommand(binary_cmd).run(cwd=working_directory)

        sim_cmd = f'vvp -n {self.dut_exe} +SIGNATURE_PATH={sig_file} +BINARY_PATH={binary_path}'
        utils.shellCommand(sim_cmd).run(cwd=working_directory)
