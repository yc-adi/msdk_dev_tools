#!/usr/bin/bash

echo
echo "############################################################################################################"
echo "# single_board_per_test.sh                                                                                 #"
echo "# usage:                                                                                                   #"
echo "#   ./single_board_per_test.sh /path/of/MSDK /path/of/RF-PHY-closed board                                  #"
echo "############################################################################################################"
echo
echo $0 $@
echo

# Example:
# 
if [[ $# -ne 3 ]]; then
    echo "usage: ./single_board_per_test.sh /path/of/MSDK /path/of/RF-PHY-closed HH:MM board"
    exit 1
fi

if [ ! -d "$1" ]; then
    echo "Invalid MSDK path."
    exit 2
fi
MSDK=$1

if [ ! -d "$2" ]; then
    echo "Invalid RF-PHY-closed path."
    exit 3
fi
PHY_REPO=$2

RESULT_PATH=~/Workspace/Resource_Share/Temp
if [ ! -d "${RESULT_PATH}" ]; then
    mkdir -p ${RESULT_PATH}
fi

RS_FILE=/home/$USER/Workspace/Resource_Share/boards_config.json
echo "The board info are stored in ${RS_FILE}."
echo

#--------------------------------------------------------------------------------------------------
# Get the board info from the json file
BRD1=nRF52840_1
BRD2=$3

BRD1_DAP_SN=$(python3 -c "import json; import os; obj=json.load(open('${RS_FILE}')); print(obj['${BRD1}']['DAP_sn'])")
echo BRD1_DAP_SN: ${BRD1_DAP_SN}
BRD1_HCI=$(python3 -c "import json; import os; obj=json.load(open('${RS_FILE}')); print(obj['${BRD1}']['hci_id'])")
echo BRD1_HCI: ${BRD1_HCI}
BRD1_SW_MODEL=$(python3 -c "import json; import os; obj=json.load(open('${RS_FILE}')); print(obj['${BRD1}']['sw_model'])")
echo BRD1_SW_MODEL: ${BRD1_SW_MODEL}
BRD1_SW_ST=$(python3 -c "import json; import os; obj=json.load(open('${RS_FILE}')); print(obj['${BRD1}']['sw_state'])")
echo BRD1_SW_ST: ${BRD1_SW_ST}
echo

BRD2_CHIP_LC=$(python3 -c "import json; import os; obj=json.load(open('${RS_FILE}')); print(obj['${BRD2}']['chip_lc'])")
echo BRD2_CHIP_LC: ${BRD2_CHIP_LC}
BRD2_CHIP_UC=$(python3 -c "import json; import os; obj=json.load(open('${RS_FILE}')); print(obj['${BRD2}']['chip_uc'])")
echo BRD2_CHIP_UC: ${BRD2_CHIP_UC}
BRD2_TYPE=$(python3 -c "import json; import os; obj=json.load(open('${RS_FILE}')); print(obj['${BRD2}']['type'])")
echo BRD2_TYPE: ${BRD2_TYPE}
BRD2_DAP_SN=$(python3 -c "import json; import os; obj=json.load(open('${RS_FILE}')); print(obj['${BRD2}']['DAP_sn'])")
echo BRD2_DAP_SN: ${BRD2_DAP_SN}
BRD2_DAP_ID=$(python3 -c "import json; import os; obj=json.load(open('${RS_FILE}')); print(obj['${BRD2}']['DAP_id'])")
echo BRD2_DAP_ID: ${BRD2_DAP_ID}
BRD2_HCI=$(python3 -c "import json; import os; obj=json.load(open('${RS_FILE}')); print(obj['${BRD2}']['hci_id'])")
echo BRD2_HCI: ${BRD2_HCI}
BRD2_CON=$(python3 -c "import json; import os; obj=json.load(open('${RS_FILE}')); print(obj['${BRD2}']['con_id'])")
echo BRD2_CON: ${BRD2_CON}
BRD2_SW_MODEL=$(python3 -c "import json; import os; obj=json.load(open('${RS_FILE}')); print(obj['${BRD2}']['sw_model'])")
echo BRD2_SW_MODEL: ${BRD2_SW_MODEL}
BRD2_SW_ST=$(python3 -c "import json; import os; obj=json.load(open('${RS_FILE}')); print(obj['${BRD2}']['sw_state'])")
echo BRD2_SW_ST: ${BRD2_SW_ST}
echo

#--------------------------------------------------------------------------------------------------
# Set python environment
echo "Activate conda env py3_10."
source ~/anaconda3/etc/profile.d/conda.sh
conda activate py3_10
python3 -c "import sys; print(sys.version)"
echo

#--------------------------------------------------------------------------------------------------
cd $MSDK
echo "PWD=$(pwd)"
echo

echo "Copy ${PHY_REPO} to ${MSDK}/Libraries"
#if [ -d $MSDK/Libraries/RF-PHY-closed ]; then
#    rm -rf $MSDK/Libraries/RF-PHY-closed
#fi
#cp -rp ${PHY_REPO} $MSDK/Libraries/RF-PHY-closed

#------------------------------------------------
# Get the test configuration.
CONFIG_FILE=$(python3 -c "import os; print(os.path.expanduser('~/Workspace/ci_config/RF-PHY-closed.json'))")

NO_SKIP=$(python3 -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['tests']['local_full_per_test']['no_skip'])")
echo "NO_SKIP: "${NO_SKIP}

DO_IT=$(python3 -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['tests']['local_full_per_test']['do_${BRD2_CHIP_LC}'])")
echo DO_IT: ${DO_IT}
PKG_RA=$(python3 -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['tests']['local_full_per_test']['${BRD2_CHIP_LC}_pkglen_range'])")
echo PKG_RA: ${PKG_RA}
PHY_RA=$(python3 -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['tests']['local_full_per_test']['${BRD2_CHIP_LC}_phy_range'])")
echo PHY_RA: ${PHY_RA}
STEP=$(python3 -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['tests']['local_full_per_test']['${BRD2_CHIP_LC}_step'])")
echo STEP: ${STEP}
echo

echo "#--------------------------------------------------------------------------------------------"
echo "# PER test on board ${BRD2}"
echo "#--------------------------------------------------------------------------------------------"
echo

python3 ~/Workspace/Resource_Share/Resource_Share.py -l -t 3600 /home/$USER/Workspace/Resource_Share/mc_rf_sw.txt
python3 ~/Workspace/Resource_Share/Resource_Share.py -l -t 3600 /home/$USER/Workspace/Resource_Share/${BRD1}.txt
python3 ~/Workspace/Resource_Share/Resource_Share.py -l -t 3600 /home/$USER/Workspace/Resource_Share/${BRD2}.txt

start_time=$(date)
start_secs=$(date +%s)
echo `date`
echo

#------------------------------------------------
echo "Disable UART assertion."
cd $MSDK
echo PWD: `pwd`
echo

set +e
sed -i "s/ PAL_SYS_ASSERT(result3 == 0)/ \/\/PAL_SYS_ASSERT(result3 == 0)/g" Libraries/Cordio/platform/targets/maxim/max32655/sources/pal_uart.c || true
cat Libraries/Cordio/platform/targets/maxim/max32655/sources/pal_uart.c | grep PAL_SYS_ASSERT\(result[0-3]
echo
sed -i "s/ PAL_SYS_ASSERT(result3 == 0)/ \/\/PAL_SYS_ASSERT(result3 == 0)/g" Libraries/Cordio/platform/targets/maxim/max32690/sources/pal_uart.c || true
cat Libraries/Cordio/platform/targets/maxim/max32690/sources/pal_uart.c | grep PAL_SYS_ASSERT\(result[0-3]
echo
set -e

echo "#--------------------------------------------------------------------------------------------"
echo "Set the Mini-circuits RF Switches."
set -x
echo RF switch for ${BRD1}
python3 $MSDK/Tools/Bluetooth/mc_rf_sw.py --model ${BRD1_SW_MODEL} --op set --state ${BRD1_SW_ST}
echo RF switch for ${BRD2}
python3 $MSDK/Tools/Bluetooth/mc_rf_sw.py --model ${BRD2_SW_MODEL} --op set --state ${BRD2_SW_ST}
set +x
echo

echo "#--------------------------------------------------------------------------------------------"
echo "Build the project BLE5_ctr for the 2nd board ${BRD2}"
echo

bash -e $MSDK/Libraries/RF-PHY-closed/.github/workflows/build_flash.sh \
    ${MSDK} \
    /home/$USER/Tools/openocd \
    ${BRD2_CHIP_UC} \
    ${BRD2_TYPE} \
    BLE5_ctr \
    ${BRD2_DAP_SN} \
    True \
    False
set +e
set +x
echo

echo "#--------------------------------------------------------------------------------------------"
echo "Test in different packet length, PHY, attenuation, and txPower"

i=0
res=${RESULT_PATH}/$(date +%Y-%m-%d_%H-%M-%S)
all_in_one=${res}_${BRD2_CHIP_LC}.csv
echo "packetLen,phy,atten,txPower,perMaster,perSlave" > "${all_in_one}"
step=${STEP}

for pkt_len in ${PKG_RA}
do
    for phy in ${PHY_RA}
    do
        echo "---------------------------------------------------------------------------------------------"
        echo "Next turn: pkt_len ${pkt_len}, phy ${phy}"

        echo "Program or reset the board ${BRD2}."
        if [[ $i -eq 0 ]]; then
            echo "Flash the board."            
            bash -e $MSDK/Libraries/RF-PHY-closed/.github/workflows/build_flash.sh \
                ${MSDK} \
                /home/$USER/Tools/openocd \
                ${BRD2_CHIP_UC} \
                ${BRD2_TYPE} \
                BLE5_ctr \
                ${BRD2_DAP_SN} \
                False \
                True
            
            echo "Sleep 5 secs."
            sleep 5
            echo "Continue the test."
            echo
        else
            echo "Reset the board ${BRD1}"
            set -x
            nrfjprog --family nrf52 -sn ${BRD1_DAP_SN} --debugreset
            set +x

            echo "Hard reset the board ${BRD2}."
            bash -ex $MSDK/Libraries/RF-PHY-closed/.github/workflows/hard_reset.sh ${BRD2_CHIP_LC}.cfg ${BRD2_DAP_SN} $(realpath ${MSDK}/Examples/${BRD2_CHIP_UC}/BLE5_ctr/build/${BRD2_CHIP_LC}.elf)
            set +e
            set +x
        fi

        # Run the PER test
        res_files[i]=${res}_${BRD2_CHIP_LC}_${i}.csv
        echo The test results will be saved in file ${res_files[i]}.

        slv_ser=${BRD2_HCI}
        mst_ser=${BRD1_HCI}
        
        set -x
        python3 $MSDK/Tools/Bluetooth/conn_sweep.py ${slv_ser} ${mst_ser} ${res_files[i]} \
            --stp ${BRD2_CON} --pktlen ${pkt_len} --phys ${phy} --step ${step}
        set +x

        echo "cat ${res_files[i]}"
        cat "${res_files[i]}"

        cat "${res_files[i]}" >> "${all_in_one}"  # put all results into one file

        i=$((i+1))
    done
done

# Reset the boards to end the TX
python3 $MSDK/Tools/Bluetooth/BLE_hci.py ${BRD2_HCI} -c "reset; exit"
python3 $MSDK/Tools/Bluetooth/BLE_hci.py ${BRD1_HCI} -c "reset; exit"

# Unlock even when cancelled or failed
python3 /home/$USER/Workspace/Resource_Share/Resource_Share.py /home/$USER/Workspace/Resource_Share/${BRD2}.txt
python3 /home/$USER/Workspace/Resource_Share/Resource_Share.py /home/$USER/Workspace/Resource_Share/${BRD1}.txt
python3 /home/$USER/Workspace/Resource_Share/Resource_Share.py /home/$USER/Workspace/Resource_Share/mc_rf_sw.txt

set +x 
echo "Check the locked resoure files."
ls -hal /home/$USER/Workspace/Resource_Share/*.txt
echo

echo $(date)
echo "Started at ${start_time}"
end_secs=$(date +%s)
exe_time=$((end_secs - start_secs))
echo

echo $'\n''echo "${all_in_one}"'
cat "${all_in_one}"
echo

echo "MAX32665 test is completed."
echo "#--------------------------------------------------------------------------------------------"
