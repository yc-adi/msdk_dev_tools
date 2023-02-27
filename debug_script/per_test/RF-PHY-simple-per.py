#!/usr/bin/env python3

from datetime import datetime as dt
import json
import os
import subprocess
import sys
import time


WITH_PRINT=True

TEST_ARGS = {
    "JOB_CURR_TIME": "",
    "TEST_ROOT": "",
    "CONFIG": {},
}

CHIP_BRD_TYPE = (
    ("MAX32655", "EvKit_V1", "max32655"),
    ("MAX32665", "EvKit_V1", "max32665"),
    ("MAX32690", "EvKit_V1", "max32690"),
    ("MAX32690", "WLP_V1",   "max32690_wlp")
)

TEST_PARAM = {
    "BRD1": "",
    "BRD2": "",
}

def PRINT(msg, log=True):
    """wrapper for print
    """
    if WITH_PRINT:
        print(msg)

    if log:
        pass
        # TODO


def run_cmd(cmd_in_list):
    """run the command
    """
    PRINT(f'input cmd: {cmd_in_list}')
    process = subprocess.Popen(cmd_in_list, 
                               stdout=subprocess.PIPE,
                               stderr=subprocess.PIPE)

    while True:
        output = process.stdout.readline().decode('utf-8')
        error = process.stderr.readline().decode('utf-8')

        if output == '' and error == '' and process.poll() is not None:
            break

        if error:
            print(f'ERR << {error.strip()}', file=sys.stderr)
            # TODO: process.terminate()

        if output:
            print(output.strip())

    exit_code = process.wait()
    # TODO

    return exit_code


def setup_test_env():
    """setup the test environment
    """
    global TEST_ARGS

    # get the configurations
    cmd = ['bash', '~/Workspace/yc/msdk_dev_tools/debug_script/per_test/setup_test_env.sh', TEST_ARGS["CURR_JOB_TIME"]]
    ret = run_cmd(cmd)
    return ret


def get_config():
    """get the configurations"""
    global TEST_ARGS

    config_file = TEST_ARGS["CONFIG_FILE"]
    ci_test = "simple_per.yml"
    obj=json.load(open(config_file))
    TEST_ARGS["CONFIG"] = obj['tests'][ci_test]


def get_test_param(uc, brd_type, chip_and_brd_type):
    """get the parameters of the PER test"""
    global TEST_ARGS
    global TEST_PARAM

    config_file = TEST_ARGS["CONFIG_FILE"]

    # BRD1=`python3 -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['used_boards']['$(hostname)']['${chip_and_board_type}'][0])"`
    # BRD2=`python3 -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['used_boards']['$(hostname)']['${chip_and_board_type}'][1])"`
    obj = json.load(open(config_file)
    TEST_ARGS["BRD_CONFIG"] = obj['used_boards']['wall-e']
    TEST_PARAM["BRD1"] = TEST_ARGS["BRD_CONFIG"][chip_and_brd_type][0]
    TEST_PARAM["BRD2"] = TEST_ARGS["BRD_CONFIG"][chip_and_brd_type][1]

    # BRD1_DAP_SN=$(python3 -c "import json; import os; obj=json.load(open('${RS_FILE}')); print(obj['${BRD1}']['DAP_sn'])")
    rs_obj = json.load(open(TEST_ARGS["RS_FILE"])
    TEST_ARGS["RS_CONFIG"] = rs_obj

def run_tests():
    """run the per tests on all boards"""
    for chip_brd_type in CHIP_BRD_TYPE:
        chip_uc = chip_brd_type[0]
        chip_lc = chip_uc.lower()
        brd_type = chip_brd_type[1]
        chip_and_brd_type = chip_brd_type[2]

        brd_test_res = test_board(chip_uc, brd_type, chip_and_board_type)


def test_board(uc, type, chip_and_brd_type):
    """test on a board
    Example:

    """
    print("#----------------------------------------------------------------------------------------------------------")
    print(f'# test {uc} {type}')
    print("#----------------------------------------------------------------------------------------------------------")

    get_test_param(uc, type, chip_and_brd_type)

    # sed -i "s/ PAL_SYS_ASSERT(result3 == 0)/ \/\/PAL_SYS_ASSERT(result3 == 0)/g" Libraries/Cordio/platform/targets/maxim/max32655/sources/pal_uart.c || true
    file = TEST_ARGS["TEST_ROOT"] + "/Libraries/Cordio/platform/targets/maxim/" + uc.lower() + "/sources/pal_uart.c"
    cmd = ['sed', '-i', r"s/ PAL_SYS_ASSERT(result3 == 0)/ \/\/PAL_SYS_ASSERT(result3 == 0)/g", file]
    run_cmd(cmd)

    if TEST_ARGS["CONFIG"]['msdk_only'] == "0":


def lock_unlock_resource(lock, board):
    """lock or unlock the resource
    """
    py_file = os.path.expanduser("~/Workspace/Resource_Share/Resource_Share.py")

    if lock:
        cmd = ["python3", py_file, "-l", "-t", "3600", board]
    else:
        cmd = ["python3", py_file, board]

    run_cmd(cmd)


if __name__ == "__main__":
    lock_unlock_resource(True, "minicircuits_rf_switch")

    curr_job_time = dt.now().strftime("%Y-%d-%m_%H-%M-%S")
    test_root = f'/tmp/msdk/ci/per/local_test_{curr_job_time}'
    TEST_ARGS["JOB_CURR_TIME"] = curr_job_time
    TEST_ARGS["TEST_ROOT"] = test_root
    TEST_ARGS["CONFIG_FILE"] = os.path.expanduser("~/Workspace/ci_config/RF-PHY-closed.json")
    TEST_ARGS["RS_FILE"] = os.path.expanduser("~/Workspace/Resource_Share/boards_config.json")

    res = setup_test_env()

    get_config()

    run_tests()

    lock_unlock_resource(False, "minicircuits_rf_switch")


    print("DONE!")
