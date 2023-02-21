#!/usr/bin/env python3

################################################################################
# Copyright (C) 2023 Analog Devices, Inc., All Rights Reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL MAXIM INTEGRATED BE LIABLE FOR ANY CLAIM, DAMAGES
# OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
# Except as contained in this notice, the name of Maxim Integrated
# Products, Inc. shall not be used except as stated in the Maxim Integrated
# Products, Inc. Branding Policy.
#
# The mere transfer of this software does not imply any licenses
# of trade secrets, proprietary technology, copyrights, patents,
# trademarks, maskwork rights, or any other form of intellectual
# property whatsoever. Maxim Integrated Products, Inc. retains all
# ownership rights.
#
###############################################################################

import argparse
from argparse import RawTextHelpFormatter
from curses.ascii import isdigit
from datetime import datetime as dt
import json
import os
from subprocess import call, Popen, PIPE, CalledProcessError, STDOUT
import sys


WITH_PRINT = False


def PRINT(msg, log=True):
    """
    ontrolled print and log
    """
    if WITH_PRINT:
        print(msg)

    if log:
        pass
        #TODO: add log


def parse_args():
    """
    Parse the user input.
    """
    global WITH_PRINT

    desc = """
        The full PER test locally instead of using Github action.
    """

    parser = argparse.ArgumentParser(description=desc, formatter_class=RawTextHelpFormatter)

    parser.add_argument("--debug", action="store_true", help="display debug info")

    args = parser.parse_args()
    if args.debug:
        WITH_PRINT = True
    else:
        WITH_PRINT = False

    msg = f'User input: {args}'
    PRINT(msg, log=True)


def run_script(script_file, chip_lc, brd_type):
    """
    Run a script file.
    """
    script_file = os.path.realpath(script_file)
    PRINT(f"Run script file {script_file}.")
    cmd = f'"bash", "{script_file}", "{chip_lc}", "{brd_type}"'
    PRINT(f'{cmd}')
    p = Popen(["bash", f"{script_file}", f"{chip_lc}", f"{brd_type}"], 
              stdout=PIPE, stderr=PIPE, shell=True)

    for line in iter(p.stdout.readline, b''):
        PRINT(f'{dt.now()} - {line.strip().decode("utf-8")}')
    
    p.stdout.close()
    p.wait()
    result = p.returncode

    PRINT(f'Return: {result}')
    return result


class Namespace:
    """
    Namespace class isused to create function arguments similar to argparse.

    """
    def __init__(self, **kwargs):
        self.__dict__.update(kwargs)


class PerFullTest(object):
    """
    PER full test class. Github has a running time limit for an action workflow. For the long time PER full test, it
    is necessary to run it locally instead of on Github.
    """
    config_file = os.path.expanduser("~/Workspace/ci_config/msdk.json")
    ci_test = "local_full_per_test"
    all_dut = {
        "max32655": {"chip_lc": "max32655", "brd_type": "EvKit_V1"},
        "max32665": {"chip_lc": "max32665", "brd_type": "EvKit_V1"},
        "max32690": {"chip_lc": "max32690", "brd_type": "EvKit_V1"},
        "max32690_wlp":   {"chip_lc": "max32690", "brd_type": "WLP_V1"}
    }

    def __init__(self, args):
        """
        Setup the test configurations from the input arguments and configuration file.
        """
        self.get_config()
        
        self.run_test()

    def get_config(self):
        """
        Get the test configuration.
        """
        json_obj = json.load(open(self.config_file))
        self.repo = json_obj["tests"][self.ci_test]["repo"]
        msg = f'used repo: {self.repo}'
        PRINT(msg)

        self.commit_id = json_obj["tests"][self.ci_test]["commit_id"]
        msg = f'checkout version: {self.commit_id}'
        PRINT(msg)

        self.limit = json_obj["tests"][self.ci_test]["limit"]
        msg = f'PER limit: {self.limit}'
        PRINT(msg)

        self.retry_limit = json_obj["tests"][self.ci_test]["retry_limit"]
        msg = f'Allowed retry times: {self.retry_limit}'
        PRINT(msg)

        self.start_time = json_obj["tests"][self.ci_test]["start_time"]
        msg = f'Test start time: {self.start_time}'
        PRINT(msg)

        for dut in self.all_dut.keys():
            PRINT(f'DUT: {dut}')
            self.all_dut[dut]["do"] = json_obj["tests"][self.ci_test]["do_" + dut]
            PRINT(f'do_{dut}: {self.all_dut[dut]["do"]}')

            self.all_dut[dut]["pkglen_range"] = json_obj["tests"][self.ci_test][dut + "_pkglen_range"]
            PRINT(f'{dut}_pkglen_range: {self.all_dut[dut]["pkglen_range"]}')

            self.all_dut[dut]["phy_range"] = json_obj["tests"][self.ci_test][dut + "_phy_range"]
            PRINT(f'{dut}_phy_range: {self.all_dut[dut]["phy_range"]}')

            self.all_dut[dut]["attens"] = json_obj["tests"][self.ci_test][dut + "_attens"]
            PRINT(f'{dut}_attens: {self.all_dut[dut]["attens"]}')

            self.all_dut[dut]["step"] = json_obj["tests"][self.ci_test][dut + "_step"]
            PRINT(f'{dut}_step: {self.all_dut[dut]["step"]}')

            PRINT("")
        
        PRINT(f'all_dut: {self.all_dut}')


    def run_test(self):
        """
        Run the fulll PER test.
        """
        for dut in self.all_dut.keys():
            PRINT("----------------------------------------------------------------------------------------------------")
            PRINT(f'Test {dut}')
            arg = self.all_dut[dut]
            PRINT(f'{arg}')

            if self.all_dut[dut]["do"] != "1":
                PRINT("Skip the test.")
                return 0

            run_script("per_on_single_dut.sh", self.all_dut[dut]["chip_uc"], self.all_dut[dut]["brd_type"])


if __name__ == '__main__':
    user_input = parse_args()

    tester = PerFullTest(user_input)

    print("Done!")




