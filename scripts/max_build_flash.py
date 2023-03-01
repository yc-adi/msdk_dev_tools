#!/usr/bin/env python3
# -*- coding:utf-8 -*-

# @Filename: max_build_flash.py

"""
Example:
    ./max_build_flash.py --msdk ~/Workspace/msdk_open --openocd ~/Tools/openocd --board max32655_board_y1 --project BLE5_ctr --build --flash

    ./max_build_flash.py --msdk ~/Workspace/msdk_open --openocd ~/Tools/openocd --board max32690_board_3 --project Hello_World --build --flash

    ./max_build_flash.py --msdk ~/Workspace/yc/msdk_open --openocd ~/Tools/openocd --board max32690_board_A1 --project BLE5_ctr --build --flash
"""

from argparse import ArgumentParser
from datetime import datetime as dt
import json
import os
from pprint import pprint
from subprocess import call, Popen, PIPE, CalledProcessError, STDOUT
import sys
import time


ERR_CODE = {
    0: "0",  # NO ERROR
    1: "INVALID ARGUMENTS",
    11: "INVALID FILE",
    12: "EXCEPTION IN SUBPROCESS"
}


def run_file(file_name: str, args:dict) -> int:
    """run a script file

        @:param

    """
    if not os.path.exists(file_name):
        print(f'File "{file_name}" not exist.')
        return 11

    # ---------------------------------------------------------------------------------------------
    # Validate the arguments
    

    try:
        file_name = os.path.realpath(file_name)
        print(f'Program: {file_name}')
        p = Popen([f'{file_name} {args["msdk"]} {args["openocd"]} {args["target"]} {args["board_type"]} ' 
                   f'{args["project"]} {args["ser_sn"]} {args["build"]} {args["flash"]} 2>&1 | tee temp.log'], 
                    stdout=PIPE, stderr=PIPE, shell=True)

        for line in iter(p.stdout.readline, b''):
            print(f'{dt.now()} - {line.strip().decode("utf-8")}')
        
        p.stdout.close()
        p.wait()

        return p.returncode

    except Exception as e:
        print(f'Error: {e}')
        p.stdout.close()
        return 12


def parse_args() -> dict:
    """parse the program arguments
    
        Example:
        ./max_build_flash.py --msdk ~/Workspace/msdk_open --openocd ~/Tools/openocd --board max32655_board_y1 --project BLE5_ctr

        ./max_build_flash.py --msdk ~/Workspace/yc/msdk_open --openocd ~/Tools/openocd --board max32690_board_w2 --project Hello_World
        ./max_build_flash.py --msdk ~/Workspace/yc/msdk_open --openocd ~/Tools/openocd --board max32690_board_w2 --project BLE5_ctr
    """
    parser = ArgumentParser(description="Flash a board with selected program.")
    parser.add_argument("--msdk", type=str, default="~/Workspace/msdk_open",
                        help="folder of the MSDK repo")
    parser.add_argument("--openocd", type=str, default="~/Tools/openocd",
                        help="the OpenOCD path")
    parser.add_argument("--board", type=str, default="max32655_board_y1",
                        help="the selected board in ~/Workspace/Resource_Share/boards_config.json")
    parser.add_argument("--project", type=str, default="BLE5_ctr",
                        help="project name")
    parser.add_argument("--build", action="store_true", help="build the project")
    parser.add_argument("--flash", action="store_true")

    args = parser.parse_args()

    print(f'Arguments: {args}')

    return vars(args)
    

def validate_args(input_args: dict) -> dict:
    """validate the input arguments"""
    # TODO

    # Parse the board configuration file to get the corresponding parameters.
    file = os.path.expanduser('~/Workspace/Resource_Share/boards_config.json')
    print(f'The board configuration file: {file}.')
    json_obj = json.load(open(file))
    #pprint(json_obj)

    input_args["target"] = json_obj[input_args["board"]]["chip_uc"]
    input_args["board_type"] = json_obj[input_args["board"]]["type"]
    input_args["ser_sn"] = json_obj[input_args["board"]]["DAP_sn"]

    pprint(input_args)

    return input_args


def main(args: dict):
    print("----------------------------------------------------------------------------------------")

    inputs = validate_args(args)
    
    ret = run_file("build_flash.sh", inputs)

    if ret in ERR_CODE.keys():
        print(f'Return: {ERR_CODE[ret]}')
    else:
        print(f'Return unknown error: {ret}.')


if __name__ == "__main__":
    args = parse_args()

    main(args)

    print("----------------------------------------------------------------------------------------")
    print("Done!")