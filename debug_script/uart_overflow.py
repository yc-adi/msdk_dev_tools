#!/usr/bin/env python3


import json
import . scripts/max_build_flash
import os
from pprint import pprint
import sys

path = os.path.expanduser("~/Workspace/msdk_open/Tools/Bluetooth")
sys.path.append(path)
import BLE_hci
from mini_RCDAT_USB import mini_RCDAT_USB
from BLE_hci import Namespace
import BLE_hci

import time
from time import sleep


def single_per_test(args, atten=20, packetLen=150, phy=1, txPower=0, rf_switch=False, delay=0.1, timeout=1):
    """run per test for selected length, TxPower"""
    # Create the BLE_hci objects
    hciMaster = BLE_hci.BLE_hci(Namespace(serialPort=args["masterSerial"], monPort=args["mtp"], baud=115200, id=1))
    hciSlave  = BLE_hci.BLE_hci(Namespace(serialPort=args["slaveSerial"],  monPort=args["stp"], baud=115200, id=2))

    # Borrow the code from msdk Tools/Bluetooth/conn_sweep.py.
    per_100 = 0
    RETRY = 2
    perMax = 0.0
    while per_100 < RETRY:
        start_secs = time.time()
        print(f'\n---------------------------------------------------------------------------------------')
        print(f'packetLen: {packetLen}, phy: {phy}, atten: {atten}, txPower: {txPower}\n')

        print("\nReset the devices.")
        hciSlave.resetFunc(None)
        hciMaster.resetFunc(None)
        sleep(0.1)

        print("\nReset the attenuation to 30.")
        if rf_switch:
            mini_RCDAT = mini_RCDAT_USB(Namespace(atten=30))
        sleep(0.1)

        print("\nSet the PHY.")
        hciMaster.phyFunc(Namespace(phy=str(phy)))
        #hciMaster.listenFunc(Namespace(time=2, stats="False"))

        print("\nSet the txPower.")
        hciSlave.txPowerFunc(Namespace(power=txPower, handle="0")) 
        hciMaster.txPowerFunc(Namespace(power=txPower, handle="0"))
        #hciSlave.listenFunc(Namespace(time=1, stats="False"))

        print("\nSet addresses.")
        txAddr = "00:12:34:88:77:33"
        rxAddr = "11:12:34:88:77:33"
        hciSlave.addrFunc(Namespace(addr=txAddr))
        hciMaster.addrFunc(Namespace(addr=rxAddr))

        print("\nStart advertising.")
        hciSlave.advFunc(Namespace(interval="60", stats="False", connect="True", maintain=False, listen="False"))
        print("\nStart connection.")
        hciMaster.initFunc(Namespace(interval="6", timeout="64", addr=txAddr, stats="False", maintain=False, listen="False"))
        
        print('--------------')
        print(f'packetLen: {packetLen}, phy: {phy}, atten: {atten}, txPower: {txPower}\n')
    
        print("Set the requested attenuation.")
        if rf_switch:
            mini_RCDAT = mini_RCDAT_USB(Namespace(atten=atten))
        sleep(0.1)

        print("\nReset the packet stats.")
#        hciSlave.cmdFunc(Namespace(cmd="0102FF00"), timeout=0.5)
        hciSlave.cmdFunc(Namespace(cmd="0102FF00"))
#        hciMaster.cmdFunc(Namespace(cmd="0102FF00"), timeout=0.5)
        hciMaster.cmdFunc(Namespace(cmd="0102FF00"))
        hciSlave.listenFunc(Namespace(time=1, stats="False"))

        print(f"\nWait {delay} secs for the TX to complete.")
        sleep(int(delay))

        print("\nRead any pending events.")
        hciSlave.listenFunc(Namespace(time=1, stats="False"))
        hciMaster.listenFunc(Namespace(time=1, stats="False"))

        print("\nCollect results.")
        perMaster = hciMaster.connStatsFunc(None)
        perSlave = hciSlave.connStatsFunc(None)

        print("perMaster  : ", perMaster)
        print("perSlave   : ", perSlave)

        if perMaster is None or perSlave is None:
            per_100 += 1
            print(f'Retry: {per_100}')
            continue

        # Record max per
        if perMaster > perMax:
            perMax = perMaster
        if perSlave > perMax:
            perMax = perSlave
        print("perMax     : ", perMax)

        break

    if per_100 >= RETRY:
        print(f'Tried {per_100} times, give up.')
        perMaster = 100
        perSlave = 100
        perMax = 100

    # Save the results to file
    end_secs = time.time()
    print(f'\nUsed {(end_secs - start_secs):.0f} seconds.')

    return 0


def main(args):
    res = single_per_test(args)


if __name__ == '__main__':
    input_args = dict()

    # Parse the board configuration file to get the corresponding parameters.
    file = os.path.expanduser('~/Workspace/Resource_Share/boards_config.json')
    print(f'The board configuration file: {file}.')
    json_obj = json.load(open(file))
    pprint(json_obj)

    board1 = "max32655_board_y1"
    board2 = "max32655_board_y2"

    input_args["target"] = json_obj[board1]["target_upper"]
    input_args["board_type"] = json_obj[board2]["type"]

    input_args["masterSerial"] = json_obj[board1]["hci"]
    input_args["slaveSerial"] = json_obj[board2]["hci"]
    input_args["mtp"] = json_obj[board1]["cn1"]
    input_args["stp"] = json_obj[board2]["cn1"]

    # flash board 1
    flash_args = dict()
    flash_args["msdk"] = "~/Workspace/msdk_open"
    flash_args["openocd"] = "~/Tools/openocd"
    flash_args["board"] = board1
    flash_args["project"] = "BLE5_ctr"


    # flash board 2


    main(input_args)

    print("DONE!")
