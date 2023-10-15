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
        self.compiler_name_prefix = config['compiler_name_prefix']

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
        # we will iterate over each entry in the testList. Each entry node will
        # be referred to by the variable testname.
        for test_name in test_list:
            logger.info(f'Running Test: {test_name} on DUT')

            test_entry = test_list[test_name]
            test_source_path = test_entry['test_path']
            working_directory = test_entry['work_dir']

            logger.info(f'Working in: {working_directory}')
            # name of the signature file as per requirement of RISCOF. RISCOF
            # expects the signature to be named as DUT-<dut-name>.signature. The
            # below variable creates an absolute path of signature file.
            sig_file = os.path.join(working_directory, self.name[:-1] + ".signature")

            compile_macros = ' -D' + " -D".join(test_entry['macros'])

            logger.info(f'Compiling test: {test_source_path}')
            cmd = (f'{self.compiler_name_prefix}-gcc '
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
            logger.info(f'Compile test: {cmd}')
            utils.shellCommand(cmd).run(cwd=working_directory)

            binary_path = os.path.join(working_directory, 'test.bin')
            binary_cmd = f'{self.compiler_name_prefix}-objcopy -O binary test.elf {binary_path}'
            logger.info('Convert to binary: ' + binary_cmd)
            utils.shellCommand(binary_cmd).run(cwd=working_directory)

            sim_cmd = f'vvp -n {self.dut_exe} +SIGNATURE_PATH={sig_file} +BINARY_PATH={binary_path}'
            logger.info(f'Executing simulator: {sim_cmd}')
            utils.shellCommand(sim_cmd).run(cwd=working_directory)
