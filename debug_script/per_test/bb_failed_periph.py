#! /usr/bin/env python3

################################################################################
 # Copyright (C) 2020 Maxim Integrated Products, Inc., All Rights Reserved.
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

## conn_sweep.py
 #
 # Sweep connection parameters.
 #
 # Ensure that both targets are built with BT_VER := 9
 #


from datetime import datetime as dt
import sys
import argparse
from argparse import RawTextHelpFormatter
from time import sleep
import itertools
from BLE_hci import BLE_hci
from BLE_hci import Namespace
import os
from pprint import pprint
import socket
from subprocess import call, Popen, PIPE, CalledProcessError, STDOUT
import time

total_retry_times = 0

if socket.gethostname() == "wall-e":
    rf_switch = True
else:
    rf_switch = False


def run_script_reset_board(sh_file):
    """call a prepared script file to reset a board"""
    sh_file = os.path.realpath(sh_file)
    print(f"Run script file {sh_file}.")
    p = Popen([f'{sh_file}'], stdout=PIPE, stderr=PIPE, shell=True)

    for line in iter(p.stdout.readline, b''):
        print(f'{dt.now()} - {line.strip().decode("utf-8")}')

    p.stdout.close()
    p.wait()
    result = p.returncode
    print(f'Exit: {result}')
    return result


# Setup the command line description text
descText = """
Connection sweep.

This tool uses a Mini Circuits RCDAT to control attenuation between two devices
running DTM software. A connection is created and PER data is gathered based on a
combination of parameters.
"""

# Parse the command line arguments
parser = argparse.ArgumentParser(description=descText, formatter_class=RawTextHelpFormatter)
parser.add_argument('--mst_hci',help='Serial port for master device')
parser.add_argument('--slv_hci',help='Serial port for slave device')
parser.add_argument('--slv_con',help='Serial port for slave TRACE info')

args = parser.parse_args()

print("--------------------------------------------------------------------------------------------\n")
pprint(vars(args))

packetLengths    = 250
phys             = 1
txPowers         = 0

packetLen        = 0
phy              = 1
txPower          = 0

print("masterSerial  :", args.mst_hci)

print(f'{dt.now()} ---- Sleep 5 secs. Cycle the power of the ME18')
sleep(3)
#hciSlv = BLE_hci(Namespace(serialPort=args.slv_hci, monPort=args.slv_con, baud=115200, id=2))
sleep(2)
print(f'{dt.now()} ---- end sleep')

# Create the BLE_hci objects
hciMaster = BLE_hci(Namespace(serialPort=args.mst_hci, monPort="", baud=115200, id=1))

ABORTED = False
perMax = 0
need_to_setup = True  # only do it at the beginning or after flash

while True:
    if need_to_setup:
        start_secs = time.time()

        print("\nSet addresses.")
        rxAddr = "11:22:33:44:55:01"
        txAddr = "00:18:80:B3:87:CC"
        hciMaster.addrFunc(Namespace(addr=rxAddr))
        sleep(1)

        print("\nReset the devices at the beginning of the test or after flash the board again.")
        hciMaster.resetFunc(None)
        sleep(1)

        print("\n----------------------------------")
        print("pre-test setup")
        print("----------------------------------")

        print("\nStart connection.")
        hciMaster.initFunc(Namespace(interval="18", timeout="200", addr=txAddr, stats="False", maintain=False, listen="False"))
        sleep(0.2)

        print(f'\n{dt.now()} ---- sleep 20 secs')
        sleep(20)
        print(f'{dt.now()} ---- end sleep')

        #print(f'Close connection')
        #hciMaster.cmdFunc(Namespace(cmd="01060403000013"))

        print("\nReset the devices at the beginning of the test or after flash the board again.")
        hciMaster.resetFunc(None)
        sys.exit(0)

        print("\nSlave and master listenFunc")
        hciSlave.listenFunc(Namespace(time=1, stats="False"))
        hciMaster.listenFunc(Namespace(time=1, stats="False"))

        print("\nSlave and master dataLenFunc")
        hciSlave.dataLenFunc(None)
        hciMaster.dataLenFunc(None)

        print("\nSlave listenFunc")
        hciSlave.listenFunc(Namespace(time=1, stats="False"))

        print("\nMaster set PHY and listenFunc.")
        hciMaster.phyFunc(Namespace(phy=str(phy)), timeout=1)
        hciMaster.listenFunc(Namespace(time=2, stats="False"))

        print("\nSlave and master set the txPower.")
        hciSlave.txPowerFunc(Namespace(power=txPower, handle="0"))
        hciMaster.txPowerFunc(Namespace(power=txPower, handle="0"))

        print("\nSlave listenFunc")
        hciSlave.listenFunc(Namespace(time=1, stats="False"))

        print("\nSlave and master sinkAclFunc")
        hciSlave.sinkAclFunc(None)
        hciMaster.sinkAclFunc(None)

        print("\nslave listenFunc, 1 sec")
        hciSlave.listenFunc(Namespace(time=1, stats="False"))

        #break

        print("\nSlave and master sendAclFunc, slave listenFunc")
        hciSlave.sendAclFunc(Namespace(packetLen=str(packetLen), numPackets=str(0)))
        hciMaster.sendAclFunc(Namespace(packetLen=str(packetLen), numPackets=str(0)))
        hciSlave.listenFunc(Namespace(time=1, stats="False"))
        hciMaster.listenFunc(Namespace(time=1, stats="False"))

        #break

    start_secs = time.time()

    print('\n---------------------------')
    print(f'packetLen: {packetLen}, phy: {1}, atten: {20}, txPower: {0}')
    print('---------------------------')

    print(f"\nSet the requested attenuation: {20}.")

    print("\nSleep 1 second")
    sleep(1)

    print("\nReset the packet stats.")
    hciMaster.cmdFunc(Namespace(cmd="0102FF00"), timeout=10.0)

    print("\nSlave listenFunc")
    print(f'used {(time.time() - start_secs):.0f} secs.')

    print("\nMaster listenFunc")
    hciMaster.listenFunc(Namespace(time=1, stats="False"))

    print(f"\nsleep args.delay {args.delay} secs")
    sleep(int(args.delay))

    print("\nRead any pending events. slave and master listenFunc")
    hciMaster.listenFunc(Namespace(time=1, stats="False"))

    print("\nMaster collects results.")
    perMaster = hciMaster.connStatsFunc(None)

    print("\nSlave collects results.")

    print("perMaster  : ", perMaster)

    break


print('--------------------------------------------------------------------------------------------')


print(f'\n{dt.now()} ---- sleep 30 secs')
sleep(30)
print(f'{dt.now()} ---- end sleep')


print("Reset the devices.")
hciMaster.resetFunc(None)
sleep(0.1)
