#!/usr/bin/env bash

MSDK=~/Workspace/msdk_open
#cd ${MSDK}/.github/workflows/scripts
echo "       PWD:" `pwd`
echo

FILE=/home/$USER/Workspace/ci_config/boards_config.json

dut_uart=$(/usr/bin/python3   -c "import sys, json; print(json.load(open('$FILE'))['max32655_board_y2']['con_sn'])")
dut_serial=$(/usr/bin/python3 -c "import sys, json; print(json.load(open('$FILE'))['max32655_board_y2']['DAP_sn'])")

echo "  dut_uart:" ${dut_uart}
echo "dut_serial:" ${dut_serial}

./test_launcher_frm_msdk.sh max32655 $dut_uart $dut_serial "ota" "EvKit_V1" $MSDK 2>&1 | tee ~/Workspace/msdk_dev_tools/debug_script/ota/test_cgm.log

#./test_launcher.sh max32655 $dut_uart $dut_serial "ota" "" "BLE_otas" 2>&1 | tee ~/Workspace/msdk_dev_tools/debug_script/ota/test_otas.log

