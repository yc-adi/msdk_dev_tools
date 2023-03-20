#!/usr/bin/env bash

cd ~/Workspace/msdk_dev_tools/debug_script/per_test
echo "PWD: " `pwd`
echo

# Use python 3.10.9
source ~/anaconda3/etc/profile.d/conda.sh && conda activate py3_10
python3 -c "import sys; print(sys.version)"
echo "use python 3.10.9"

function test_me17
{
    # On Ying's Ubuntu
    # nRF52840_2 and max32655_board_y1
    #"DAP_sn": "1050288497"
    #
    # ~/Workspace/msdk_dev_tools/scripts/max_build_flash.py --msdk ~/Workspace/msdk_open --openocd ~/Tools/openocd --board max32655_board_y1 --project BLE5_ctr --build --flash

    brd1_hci="/dev/serial/by-id/usb-SEGGER_J-Link_001050288497-if00"

    brd2_hci="/dev/serial/by-id/usb-FTDI_FT230X_Basic_UART_DT03OFRJ-if00-port0"
    brd2_con="/dev/serial/by-id/usb-FTDI_FT230X_Basic_UART_D3073IDG-if00-port0"

    cd ~/Workspace/msdk_dev_tools/debug_script/per_test
    echo "unbuffer ./debug_bb_failed.py --mst_hci ${brd1_hci} --slv_hci ${brd2_hci} --slv_con ${brd2_con}"
    unbuffer ./debug_bb_failed.py --mst_hci ${brd1_hci} --slv_hci ${brd2_hci} --slv_con ${brd2_con}
}

function test_me18
{
    # On Ying's Ubuntu
    # nRF52840_2 and max32690_board_a3
    #"DAP_sn": "1050288497"
    #
    # ~/Workspace/msdk_dev_tools/scripts/max_build_flash.py --msdk ~/Workspace/msdk_open --openocd ~/Tools/openocd --board max32690_board_3 --project BLE5_ctr --build --flash

    brd1_hci="/dev/serial/by-id/usb-SEGGER_J-Link_001050288497-if00"

    brd2_hci="/dev/serial/by-id/usb-ARM_DAPLink_CMSIS-DAP_040917014d8e03fc00000000000000000000000097969906-if01"
    brd2_con="/dev/serial/by-id/usb-FTDI_FT231X_USB_UART_D30ALJPW-if00-port0"

    cd ~/Workspace/msdk_dev_tools/debug_script/per_test
    #echo "unbuffer ./debug_bb_failed.py --mst_hci ${brd1_hci} --slv_hci ${brd2_hci} --slv_con ${brd2_con}"
    #unbuffer ./debug_bb_failed.py --mst_hci ${brd1_hci} --slv_hci ${brd2_hci} --slv_con ${brd2_con}

    echo "unbuffer ./test_me18.py --mst_hci ${brd1_hci} --slv_hci ${brd2_hci} --slv_con ${brd2_con}"
    unbuffer ././test_me18.py --mst_hci ${brd1_hci} --slv_hci ${brd2_hci} --slv_con ${brd2_con} 2>&1 | tee test_me18.log 
}

function test_me18_no_con
{
    # On Ying's Ubuntu
    # nRF52840_2 and max32690_board_A5
    #"DAP_sn": "1050288497"
    #
    # ~/Workspace/msdk_dev_tools/scripts/max_build_flash.py --msdk ~/Workspace/msdk_open --openocd ~/Tools/openocd --board max32690_board_3 --project BLE5_ctr --build --flash

    brd1_hci="/dev/serial/by-id/usb-SEGGER_J-Link_001050288497-if00"

    brd2_hci="/dev/serial/by-id/usb-ARM_DAPLink_CMSIS-DAP_040917014d8e03fc00000000000000000000000097969906-if01"
    brd2_con="/dev/serial/by-id/usb-FTDI_FT231X_USB_UART_D30ALJPW-if00-port0"

    cd ~/Workspace/msdk_dev_tools/debug_script/per_test
    echo "unbuffer ./debug_bb_failed.py --mst_hci ${brd1_hci} --slv_hci ${brd2_hci}"
    unbuffer ./debug_bb_failed.py --mst_hci ${brd1_hci} --slv_hci ${brd2_hci}
}

function ver_me18
{
    # On Ying's Ubuntu
    # nRF52840_2 and max32690_board_A5
    #"DAP_sn": "1050288497"
    #
    # ~/Workspace/msdk_dev_tools/scripts/max_build_flash.py --msdk ~/Workspace/msdk_open --openocd ~/Tools/openocd --board max32690_board_3 --project BLE5_ctr --build --flash

    brd1_hci="/dev/serial/by-id/usb-SEGGER_J-Link_001050288497-if00"

    brd2_hci="/dev/serial/by-id/usb-ARM_DAPLink_CMSIS-DAP_040917014d8e03fc00000000000000000000000097969906-if01"
    brd2_con="/dev/serial/by-id/usb-FTDI_FT231X_USB_UART_D30ALJPW-if00-port0"

    cd ~/Workspace/msdk_dev_tools/debug_script/per_test
    echo "unbuffer ./bb_failed_verify.py --mst_hci ${brd1_hci} --slv_hci ${brd2_hci} --slv_con ${brd2_con}"
    unbuffer ./bb_failed_verify.py --mst_hci ${brd1_hci} --slv_hci ${brd2_hci} --slv_con ${brd2_con} 2>&1 | tee me18_ref.log
}


function test_me18_wlp
{
    # On Ying's Ubuntu
    # nRF52840_2 and max32690_board_A5
    #"DAP_sn": "1050288497"
    #
    # ~/Workspace/msdk_dev_tools/scripts/max_build_flash.py --msdk ~/Workspace/msdk_open --openocd ~/Tools/openocd --board max32690_board_A5 --project BLE5_ctr --build --flash

    brd1_hci="/dev/serial/by-id/usb-SEGGER_J-Link_001050288497-if00"

    brd2_dap="/dev/serial/by-id/usb-ARM_DAPLink_CMSIS-DAP_040917012a8e03a400000000000000000000000097969906-if01"
    brd2_hci="/dev/serial/by-id/usb-FTDI_FT231X_USB_UART_D30ALWEM-if00-port0"
    brd2_con="/dev/serial/by-id/usb-FTDI_FT231X_USB_UART_D30ALWEN-if00-port0"

    cd ~/Workspace/msdk_dev_tools/debug_script/per_test
    echo "unbuffer ./test_me18_wlp.py --mst_hci ${brd1_hci} --slv_hci ${brd2_hci} --slv_con ${brd2_con} 2>&1 | tee test_me18_wlp.log"
    unbuffer ./test_me18_wlp.py --mst_hci ${brd1_hci} --slv_hci ${brd2_hci} --slv_con ${brd2_con}  2>&1 | tee test_me18_wlp.log
}


function test_me14
{
    # On Ying's Ubuntu
    # nRF52840_2 and max32665_board_2
    #"DAP_sn": "1050288497"
    #
    # ~/Workspace/msdk_dev_tools/scripts/max_build_flash.py --msdk ~/Workspace/msdk_open --openocd ~/Tools/openocd --board max32665_board_2 --project BLE5_ctr --build --flash

    brd1_hci="/dev/serial/by-id/usb-SEGGER_J-Link_001050288497-if00"

    brd2_hci="/dev/serial/by-id/usb-FTDI_FT230X_Basic_UART_DT03OGQ4-if00-port0"
    brd2_con="/dev/serial/by-id/usb-FTDI_FT230X_Basic_UART_D30A1X9V-if00-port0"

    cd ~/Workspace/msdk_dev_tools/debug_script/per_test
    echo "unbuffer ./debug_bb_failed.py --mst_hci ${brd1_hci} --slv_hci ${brd2_hci} --slv_con ${brd2_con}"
    unbuffer ./debug_bb_failed.py --mst_hci ${brd1_hci} --slv_hci ${brd2_hci} --slv_con ${brd2_con}
}


function test_me17_me18
{
    # On Ying's Ubuntu
    # LT: max32655_board_y1
    # DUT: max32690_board_3
    #
    # ~/Workspace/msdk_dev_tools/scripts/max_build_flash.py --msdk ~/Workspace/msdk_open --openocd ~/Tools/openocd --board max32655_board_y1 --project BLE5_ctr --build --flash
    # ~/Workspace/msdk_dev_tools/scripts/max_build_flash.py --msdk ~/Workspace/msdk_open --openocd ~/Tools/openocd --board max32690_board_3 --project BLE5_ctr --build --flash

    # ME18
    # ./BLE_hci.py /dev/serial/by-id/usb-ARM_DAPLink_CMSIS-DAP_040917014d8e03fc00000000000000000000000097969906-if01 115200 --monPort /dev/serial/by-id/usb-FTDI_FT231X_USB_UART_D30ALJPW-if00-port0

    brd1_hci="/dev/serial/by-id/usb-FTDI_FT230X_Basic_UART_DT03OFRJ-if00-port0"
    brd1_con="/dev/serial/by-id/usb-FTDI_FT230X_Basic_UART_D3073IDG-if00-port0"

    brd2_hci="/dev/serial/by-id/usb-ARM_DAPLink_CMSIS-DAP_040917014d8e03fc00000000000000000000000097969906-if01"
    brd2_con="/dev/serial/by-id/usb-FTDI_FT231X_USB_UART_D30ALJPW-if00-port0"

    cd ~/Workspace/msdk_dev_tools/debug_script/per_test
    echo "unbuffer ./debug_bb_failed.py --mst_hci ${brd1_hci} --slv_hci ${brd2_hci} --mst_con ${brd1_con} --slv_con ${brd2_con}"
    unbuffer ./debug_bb_failed.py --mst_hci ${brd1_hci} --mst_con ${brd1_con} --slv_hci ${brd2_hci} --slv_con ${brd2_con}
}

function test_me17_me18-wlp
{
    # On Ying's Ubuntu
    # LT: max32655_board_y1
    # DUT: max32690_board_A5
    #
    # ~/Workspace/msdk_dev_tools/scripts/max_build_flash.py --msdk ~/Workspace/msdk_open --openocd ~/Tools/openocd --board max32655_board_y1 --project BLE5_ctr --build --flash
    # ~/Workspace/msdk_dev_tools/scripts/max_build_flash.py --msdk ~/Workspace/msdk_open --openocd ~/Tools/openocd --board max32690_board_A5 --project BLE5_ctr --build --flash

    # test brd1
    # ./BLE_hci.py /dev/serial/by-id/usb-FTDI_FT230X_Basic_UART_DT03OFRJ-if00-port0 115200 --monPort /dev/serial/by-id/usb-FTDI_FT230X_Basic_UART_D3073IDG-if00-port0
    # test brd2
    # ./BLE_hci.py /dev/serial/by-id/usb-FTDI_FT231X_USB_UART_D30ALWEM-if00-port0 115200 --monPort /dev/serial/by-id/usb-FTDI_FT231X_USB_UART_D30ALWEN-if00-port0

    brd1_hci="/dev/serial/by-id/usb-FTDI_FT230X_Basic_UART_DT03OFRJ-if00-port0"
    brd1_con="/dev/serial/by-id/usb-FTDI_FT230X_Basic_UART_D3073IDG-if00-port0"

    brd2_hci="/dev/serial/by-id/usb-FTDI_FT231X_USB_UART_D30ALWEM-if00-port0"
    brd2_con="/dev/serial/by-id/usb-FTDI_FT231X_USB_UART_D30ALWEN-if00-port0"

    cd ~/Workspace/msdk_dev_tools/debug_script/per_test
    echo "unbuffer ./debug_bb_failed.py --mst_hci ${brd1_hci} --mst_con ${brd1_con} --slv_hci ${brd2_hci} --slv_con ${brd2_con}"
    unbuffer ./debug_bb_failed.py --mst_hci ${brd1_hci} --mst_con ${brd1_con} --slv_hci ${brd2_hci} --slv_con ${brd2_con}
}

function test_me18_periph_nRF52840
{
# On Ying's Ubuntu
    # nRF52840_2 and max32665_board_2
    #"DAP_sn": "1050288497"
    #
    # ~/Workspace/msdk_dev_tools/scripts/max_build_flash.py --msdk ~/Workspace/msdk_open --openocd ~/Tools/openocd --board max32690_board_3 --project BLE_periph --build --flash

    brd1_hci="/dev/serial/by-id/usb-SEGGER_J-Link_001050288497-if00"

    brd2_hci="/dev/serial/by-id/usb-ARM_DAPLink_CMSIS-DAP_040917014d8e03fc00000000000000000000000097969906-if01"
    brd2_con="/dev/serial/by-id/usb-FTDI_FT231X_USB_UART_D30ALJPW-if00-port0"

    cd ~/Workspace/msdk_dev_tools/debug_script/per_test
    echo "unbuffer ./bb_failed_periph.py --mst_hci ${brd1_hci} --slv_con ${brd2_con}"
    unbuffer ./bb_failed_periph.py --mst_hci ${brd1_hci} --slv_hci ${brd2_hci} --slv_con ${brd2_con}
}

function test_me14_me18
{
    # On Ying's Ubuntu
    
    # me14
    brd1_hci="/dev/serial/by-id/usb-FTDI_FT230X_Basic_UART_DT03OGQ4-if00-port0"

    brd2_hci="/dev/serial/by-id/usb-FTDI_FT230X_Basic_UART_DT03OGQ4-if00-port0"
    brd2_con="/dev/serial/by-id/usb-FTDI_FT230X_Basic_UART_D30A1X9V-if00-port0"

    cd ~/Workspace/msdk_dev_tools/debug_script/per_test
    echo "unbuffer ./debug_bb_failed.py --mst_hci ${brd1_hci} --slv_hci ${brd2_hci} --slv_con ${brd2_con}"
    unbuffer ./debug_bb_failed.py --mst_hci ${brd1_hci} --slv_hci ${brd2_hci} --slv_con ${brd2_con}
}

function build_flash_test
{
    # $1: board
    BOARD=$1
    echo "BOARD:" $BOARD
    bash -x -c "~/Workspace/msdk_dev_tools/scripts/max_build_flash.py --msdk ~/Workspace/msdk_open --openocd ~/Tools/openocd --board $BOARD --project BLE5_ctr --build --flash"    
}

#test_me14
#test_me17
#test_me18
test_me18_wlp
#test_me17_me18
#test_me17_me18-wlp
#ver_me18

#test_me18_periph_nRF52840

echo "$0: Done!"
