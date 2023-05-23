#!/usr/bin/env bash

echo "#############################################################################################"
echo "# ./cgm_ota_demo.sh                                                                         #"
echo "#############################################################################################"
echo
echo $0 $@
echo

MSDK_DIR=~/Workspace/msdk_open
echo "              MSDK_DIR:" $MSDK_DIR
MAIN_DEVICE_NAME_UPPER=MAX32655
echo "MAIN_DEVICE_NAME_UPPER:" $MAIN_DEVICE_NAME_UPPER
MAIN_DEVICE_NAME_LOWER=${MAIN_DEVICE_NAME_UPPER,,}
echo "MAIN_DEVICE_NAME_LOWER:" $MAIN_DEVICE_NAME_LOWER
DUT_NAME_UPPER=MAX32655
echo "        DUT_NAME_UPPER:" $DUT_NAME_UPPER
DUT_NAME_LOWER=${DUT_NAME_UPPER,,}
echo "        DUT_NAME_LOWER:" $DUT_NAME_LOWER
DUT_BOARD_TYPE=EvKit_V1
echo "        DUT_BOARD_TYPE:" $DUT_BOARD_TYPE
OTA_PRJ=BLE_cgm
echo "               OTA_PRJ:" $OTA_PRJ
INTERNAL_FLASH_TEST=1
echo "   INTERNAL_FLASH_TEST:" $INTERNAL_FLASH_TEST

export OPENOCD_TCL_PATH=/home/$USER/Tools/openocd/tcl
export OPENOCD=/home/$USER/MaximSDK/Tools/OpenOCD/openocd

DUT_ID=040917015f8d03d800000000000000000000000097969906
MAIN_DEVICE_ID=040917012a8e03a400000000000000000000000097969906
echo

VERBOSE() {
    #"$@" &> /dev/null
    "$@"
    echo
}

# Function accepts parameters: device, CMSIS-DAP serial #
function flash_with_openocd() {
    # mass erase and flash
    set -x
    $OPENOCD -f $OPENOCD_TCL_PATH/interface/cmsis-dap.cfg -f $OPENOCD_TCL_PATH/target/$1.cfg -s $OPENOCD_TCL_PATH -c "cmsis_dap_serial  $2" -c "gdb_port 3333" -c "telnet_port 4444" -c "tcl_port 6666" -c "init; reset halt;max32xxx mass_erase 0" -c "program $1.elf verify reset exit"
    
    openocd_dapLink_pid=$!
    # wait for openocd to finish
    while kill -0 $openocd_dapLink_pid; do
        sleep 1
        # we can add a timeout here if we want
    done
    set +x

    # Check the return value to see if we received an error
    if [ "$?" -ne "0" ]; then
        printf "> Verify failed , flashibng again \r\n"
        # Reprogram the device if the verify failed
        set -x
        VERBOSE $OPENOCD -f $OPENOCD_TCL_PATH/interface/cmsis-dap.cfg -f $OPENOCD_TCL_PATH/target/$1.cfg -s $OPENOCD_TCL_PATH -c "cmsis_dap_serial  $2" -c "gdb_port 3333" -c "telnet_port 4444" -c "tcl_port 6666" -c "init; reset halt;max32xxx mass_erase 0" -c "program $1.elf verify reset exit" &
        set +x
        openocd_dapLink_pid=$!
    fi
}

#--------------------------------------------------------------------------------------------------
# Prepare the DUT: OTAS
#
# Make sure the firmware version is 1
cd $MSDK_DIR/Examples/$DUT_NAME_UPPER/$OTA_PRJ
echo "PWD:" `pwd`
echo

if [[ $INTERNAL_FLASH_TEST == 1 ]]; then
    set -x
    perl -i -pe "s/FW_VERSION_MAJOR 2/FW_VERSION_MAJOR 1/g" wdxs_file_int.c
    set +x
else
    perl -i -pe "s/FW_VERSION_MAJOR 2/FW_VERSION_MAJOR 1/g" wdxs_file_ext.c
fi

set -x
cd $MSDK_DIR/Examples/$DUT_NAME_UPPER/$OTA_PRJ
VERBOSE make clean MAXIM_PATH=$MSDK_DIR
VERBOSE make BOARD=$DUT_BOARD_TYPE -j8 MAXIM_PATH=$MSDK_DIR
set +x

printf "\n\n>>>>>>>> Flashing $OTA_PRJ V1 on DUT\n\n"
cd $MSDK_DIR/Examples/$DUT_NAME_UPPER/$OTA_PRJ/build
flash_with_openocd $DUT_NAME_LOWER $DUT_ID

#--------------------------------------------------------------------------------------------------
# Prepare the main device: OTAC
#
printf "\n\n<<<<<< Prepare the main device: OTAC\n\n"
cd $MSDK_DIR/Examples/$MAIN_DEVICE_NAME_UPPER/BLE_otac
echo "PWD:" `pwd`
echo

set -x
sed -i 's/BUILD_DIR=\$(FW_BUILD_DIR) BUILD_BOOTLOADER=0 PROJECT=fw_update/BUILD_DIR=\$(FW_BUILD_DIR) BUILD_BOOTLOADER=0 PROJECT=fw_update TARGET='"$DUT_NAME_UPPER"' TARGET_UC='"$DUT_NAME_UPPER"' TARGET_LC='"$DUT_NAME_LOWER"'/g' project.mk
sed -i 's/BUILD_DIR=\$(FW_BUILD_DIR) \$(FW_UPDATE_BIN)/BUILD_DIR=\$(FW_BUILD_DIR) \$(FW_UPDATE_BIN) TARGET='"$DUT_NAME_UPPER"' TARGET_UC='"$DUT_NAME_UPPER"' TARGET_LC='"$DUT_NAME_LOWER"'/g' project.mk
set +x

printf "\n\n>>>>>> change $OTA_PRJ firmware version and build the new version\n\n"
cd $MSDK_DIR/Examples/$DUT_NAME_UPPER/$OTA_PRJ
echo "PWD:" `pwd`
# change firmware version to verify otas worked
if [[ $INTERNAL_FLASH_TEST == 1 ]]; then
    set -x
    perl -i -pe "s/FW_VERSION_MAJOR 1/FW_VERSION_MAJOR 2/g" wdxs_file_int.c
    set +x
else
    perl -i -pe "s/FW_VERSION_MAJOR 1/FW_VERSION_MAJOR 2/g" wdxs_file_ext.c
fi

set -x
VERBOSE make clean
VERBOSE make BOARD=$DUT_BOARD_TYPE USE_INTERNAL_FLASH=$INTERNAL_FLASH_TEST BUILD_BOOTLOADER=0 -j8
set +x

printf "\n\n>>>>>> make OTAC and flash MAIN_DEVICE with BLE_OTAC, it will use the new $OTA_PRJ bin as the new firmware\n"
cd $MSDK_DIR/Examples/$MAIN_DEVICE_NAME_UPPER/BLE_otac
echo "PWD:" `pwd`
set -x
VERBOSE make clean
VERBOSE make BOARD=$DUT_BOARD_TYPE FW_UPDATE_DIR=../$OTA_PRJ USE_INTERNAL_FLASH=$INTERNAL_FLASH_TEST BUILD_BOOTLOADER=0 -j
set +x

cd $MSDK_DIR/Examples/$MAIN_DEVICE_NAME_UPPER/BLE_otac/build
printf "\n\n>>>>>>> Flashing BLE_otac on main device\n\n"
flash_with_openocd $MAIN_DEVICE_NAME_LOWER $MAIN_DEVICE_ID
printf "\n\n>>>>>>> Flashing done\n\n"


