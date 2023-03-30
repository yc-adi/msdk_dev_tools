#!/bin/bash

MSDK=~/Workspace/msdk_open
RF_PHY_REPO=${MSDK}/Libraries/RF-PHY-closed

cd ${RF_PHY_REPO}/MAX32690/build/gcc
echo "PWD: $(pwd)"
echo

set -x
rm ../../libphy.a
make clean
set +x

printf "\n----------------------------------\n"
printf ">>> build libphy.a"
printf "\n----------------------------------\n\n"
set -x
make all
RES=$?
set +x

if [ ${RES} -ne 0 ]; then
    printf "\n----------------------------------\n"
    printf "\nbuild result: ${RES}. FAILED!\n"
    printf "\n----------------------------------\n"
    exit 1
fi

cd ${MSDK}/Examples/MAX32690/BLE5_ctr
echo "PWD: $(pwd)"
echo

set -x
make MAXIM_PATH=${MSDK} distclean
set +x

printf "\n----------------------------------\n"
printf ">>> build BLE5_ctr"
printf "\n----------------------------------\n\n"
set -x
make -j8 MAXIM_PATH=${MSDK} BOARD=WLP_V1 PROJECT=BLE5_ctr
RES=$?
set +x

if [ ${RES} -ne 0 ]; then
    printf "\n----------------------------------\n"
    printf "\nbuild BLE5_ctr result: ${RES}. FAILED!\n"
    printf "\n----------------------------------\\nn"
    exit 1
fi

cp build/BLE5_ctr.elf build/max32690.elf

printf "\n----------------------------------\n"
printf ">>> flash BLE5_ctr to board max32690_board_A5"
printf "\n----------------------------------\n\n"
source ~/anaconda3/etc/profile.d/conda.sh && conda activate py3_10
conda activate py3_10

cd ~/Workspace/msdk_dev_tools/scripts
echo "PWD: $(pwd)"
echo

set -x
./max_build_flash.py --board max32690_board_A5 --flash
RES=$?
set +x

if [ ${RES} -ne 0 ]; then
    printf "\n----------------------------------\n"
    printf "\nflash BLE5_ctr to board A5 failed!\n"
    printf "\n----------------------------------\\nn"
    exit 1
fi




printf "\n----------------------------------\n"
printf "DONE!"
printf "\n----------------------------------\n\n"