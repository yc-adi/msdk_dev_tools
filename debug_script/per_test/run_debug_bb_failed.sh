#!/usr/bin/env bash

cd ~/Workspace/msdk_dev_tools/debug_script/per_test
echo "PWD: " `pwd`
echo

# Use python 3.10.9
source ~/anaconda3/etc/profile.d/conda.sh && conda activate py3_10
python3 -c "import sys; print(sys.version)"
echo "use python 3.10.9"

function test_me18
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
    echo "unbuffer ./debug_bb_failed.py --mst_hci ${brd1_hci} --slv_hci ${brd2_hci} --slv_con ${brd2_con}"
    unbuffer ./debug_bb_failed.py --mst_hci ${brd1_hci} --slv_hci ${brd2_hci} --slv_con ${brd2_con}
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
    echo "unbuffer ./debug_bb_failed.py --mst_hci ${brd1_hci} --slv_hci ${brd2_hci} --slv_con ${brd2_con}"
    unbuffer ./debug_bb_failed.py --mst_hci ${brd1_hci} --slv_hci ${brd2_hci} --slv_con ${brd2_con}
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

#test_me14
test_me18
#test_me17_me18
#test_me17_me18-wlp

echo "$0: Done!"
