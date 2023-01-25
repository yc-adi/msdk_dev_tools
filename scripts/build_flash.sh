#!/usr/bin/env bash

echo "#############################################################################################"
echo "# flash.sh <msdk_path> <openocd> <target_type> <board_type> <project> <port>                #"
echo "#############################################################################################"
echo

# Examples
# Board: A5
# python max_build_flash.py --msdk /home/ying-cai/Workspace/msdk_open --openocd /home/ying-cai/softwares/openocd --target MAX32690 --board_type WLP_V1   --project BLE5_ctr --ser_sn 040917012a8e03a400000000000000000000000097969906
# Board: max32655_board_y1
# python max_build_flash.py --msdk /home/ying-cai/Workspace/msdk_open --openocd /home/ying-cai/softwares/openocd --target MAX32655 --board_type EvKit_V1 --project BLE5_ctr --ser_sn 0444170169c5c14600000000000000000000000097969906

echo $@
echo

MSDK=$1
OPENOCD=$2
TARGET=$3
echo TARGET=${TARGET}
TARGET_LC=`echo $TARGET | tr '[:upper:]' '[:lower:]'`
echo TARGET_LC=${TARGET_LC}
BOARD_TYPE=$4
PROJECT=$5
PORT=$6

#--------------------------------------------------------------------------------------------------
# build the project
function build()
{
    echo "-----------------------------------------------------------------------------------------"
    echo "Build the project."
    echo

    cd $MSDK/Examples/$TARGET/$PROJECT
    echo PWD=`pwd`
    echo 

    set -e
    set -x

    make MAXIM_PATH=$MSDK distclean
    make -j8 MAXIM_PATH=$MSDK TARGET=$TARGET BOARD=$BOARD_TYPE PROJECT=$PROJECT

    set +x
    set +e
}

#--------------------------------------------------------------------------------------------------
function flash_boards()
{

    echo "-----------------------------------------------------------------------------------------"
    echo "Flas the ELF to the board."
    echo

    cd $MSDK/Examples/$TARGET/$PROJECT
    echo PWD=`pwd`
    echo

    flash_with_openocd $PROJECT.elf $PORT
}

# -------------------------------------------------------------------------------------------------
# Function accepts parameters: filename, CMSIS_DAP_ID_x 
function flash_with_openocd()
{
    echo "Board DAP: $PORT"
    cd $MSDK/Examples/$TARGET/$PROJECT/build
    echo PWD=`pwd`
    echo
    
    set -x
    
    # mass erase and flash
    $OPENOCD/src/openocd -f $OPENOCD/tcl/interface/cmsis-dap.cfg -f $OPENOCD/tcl/target/$TARGET_LC.cfg -s $OPENOCD/tcl -c "adapter serial $PORT" -c "gdb_port 3333" -c "telnet_port 4444" -c "tcl_port 6666"  -c "init; reset halt;max32xxx mass_erase 0" -c "program ${PROJECT}.elf verify reset exit" > /dev/null &
    openocd_dapLink_pid=$!

    # wait for openocd to finish
    while kill -0 $openocd_dapLink_pid &> /dev/null; do
        sleep 1
    
        # we can add a timeout here if we want
    done

    set +x
    
    # Attempt to verify the image, prevent exit on error
    $OPENOCD/src/openocd -f $OPENOCD/tcl/interface/cmsis-dap.cfg -f $OPENOCD/tcl/target/$TARGET_LC.cfg -s $OPENOCD/tcl -c "adapter serial $PORT" -c "gdb_port 3333" -c "telnet_port 4444" -c "tcl_port 6666"  -c "init; reset halt; flash verify_image $1; reset; exit"

    # Check the return value to see if we received an error
    if [ "$?" -ne "0" ]; then
        # Reprogram the device if the verify failed
        $OPENOCD/src/openocd -f $OPENOCD/tcl/interface/cmsis-dap.cfg -f $OPENOCD/tcl/target/$TARGET_LC.cfg -s $OPENOCD/tcl -c "adapter serial $PORT" -c "gdb_port 3333" -c "telnet_port 4444" -c "tcl_port 6666"  -c "init; reset halt;max32xxx mass_erase 0" -c "program $1 verify reset exit" > /dev/null &
        openocd_dapLink_pid=$!
    fi
}

# -------------------------------------------------------------------------------------------------
# Main function
function main()
{
    build
    flash_boards
}

# -------------------------------------------------------------------------------------------------
main

echo "---------------------------------------------------------------------------------------------"
echo "DONE!"
echo "---------------------------------------------------------------------------------------------"
