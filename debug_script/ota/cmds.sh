#!/usr/bin/env bash

############## !!! MODIFY THESE VARIABLES !!! ####################
MSDK=~/Workspace/msdk_open
DAP_SERIAL=044417016bd8439a00000000000000000000000097969906
OPENOCD=/home/$USER/MaximSDK/Tools/OpenOCD
OPENOCD_EXE=${OPENOCD}/openocd
GDB_DIR=~/MaximSDK/Tools/GNUTools/10.3/bin
PROJECT=BLE_FreeRTS_OTA

#--------------------------------------------------------------------------------------------------
function erase_flash
{
    printf "\n>>>>>> erase falsh\n\n"

    ${OPENOCD_EXE}                                      \
        -s ${OPENOCD}/scripts                           \
        -f ${OPENOCD}/scripts/interface/cmsis-dap.cfg   \
        -f ${OPENOCD}/scripts/target/max32655.cfg       \
        -c "cmsis_dap_serial  ${DAP_SERIAL}"            \
        -c 'gdb_port 3333'                              \
        -c 'telnet_port 4444'                           \
        -c 'tcl_port 6666'                              \
        -c 'init; reset halt; max32xxx mass_erase 0;'   \
        -c 'exit'
}

function build_flash_otas
{
    # build BLE_FreeRTOS_OTA
    cd ${MSDK}/Examples/MAX32655/${BLE_FreeRTOS_OTA}
    #make MAXIM_PATH=${MSDK} distclean
    #make MAXIM_PATH=${MSDK} BOARD=EvKit_V1 USE_INTERNAL_FLASH=1 -j8

    printf "\n>>>>>> flash ${BLE_FreeRTOS_OTA}\n\n"

    ${OPENOCD_EXE}                                      \
        -s ${OPENOCD}/scripts                           \
        -f ${OPENOCD}/scripts/interface/cmsis-dap.cfg   \
        -f ${OPENOCD}/scripts/target/max32655.cfg       \
        -c "cmsis_dap_serial  ${DAP_SERIAL}"            \
        -c 'gdb_port 3333'                              \
        -c 'telnet_port 4444'                           \
        -c 'tcl_port 6666'                              \
        -c 'init; reset halt;'                          \
        -c 'program ./build/max32655.elf verify reset exit'
}

function verify_otas
{
    printf "\n>>>>>> verify otas image\n\n"
    cd ${MSDK}/Examples/MAX32655/${BLE_FreeRTOS_OTA}
    ${OPENOCD_EXE}                                      \
        -s ${OPENOCD}/scripts                           \
        -f ${OPENOCD}/scripts/interface/cmsis-dap.cfg   \
        -f ${OPENOCD}/scripts/target/max32655.cfg       \
        -c "cmsis_dap_serial  ${DAP_SERIAL}"            \
        -c 'gdb_port 3333'                              \
        -c 'telnet_port 4444'                           \
        -c 'tcl_port 6666'                              \
        -c 'init; reset halt;'                          \
        -c 'flash verify_image ./build/max32655.elf; reset; exit'
}

function build_flash_bootloader
{
    # build Bootloader
    cd ${MSDK}/Examples/MAX32655/Bootloader
    #make MAXIM_PATH=${MSDK} distclean
    #make MAXIM_PATH=${MSDK} BOARD=EvKit_V1 USE_INTERNAL_FLASH=1 -j8

    printf "\n>>>>>> flash Bootloader\n\n"

    ${OPENOCD_EXE}                                      \
        -s ${OPENOCD}/scripts                           \
        -f ${OPENOCD}/scripts/interface/cmsis-dap.cfg   \
        -f ${OPENOCD}/scripts/target/max32655.cfg       \
        -c "cmsis_dap_serial  ${DAP_SERIAL}"            \
        -c 'gdb_port 3333'                              \
        -c 'telnet_port 4444'                           \
        -c 'tcl_port 6666'                              \
        -c 'init; reset halt'                           \
        -c 'program ./build/max32655.elf verify reset exit'
}

function verify_bootloader
{
    printf "\n>>>>>> verify Bootloader image\n\n"
    cd ${MSDK}/Examples/MAX32655/Bootloader
    ${OPENOCD_EXE}                                      \
        -s ${OPENOCD}/scripts                           \
        -f ${OPENOCD}/scripts/interface/cmsis-dap.cfg   \
        -f ${OPENOCD}/scripts/target/max32655.cfg       \
        -c "cmsis_dap_serial  ${DAP_SERIAL}"            \
        -c 'gdb_port 3333'                              \
        -c 'telnet_port 4444'                           \
        -c 'tcl_port 6666'                              \
        -c 'init; reset halt;'                          \
        -c 'flash verify_image ./build/max32655.elf; reset; exit'

    echo $?
}

function build_flash_otas_by_gdb
{
    printf "\n>>>>>> build ${BLE_FreeRTOS_OTA}\n\n"
    cd ${MSDK}/Examples/MAX32655/${BLE_FreeRTOS_OTA}
    make MAXIM_PATH=${MSDK} distclean
    make MAXIM_PATH=${MSDK} BOARD=EvKit_V1 USE_INTERNAL_FLASH=1 -j8

    printf "\n>>>>>> flash ${BLE_FreeRTOS_OTA}\n\n"
    ${GDB_DIR}/arm-none-eabi-gdb ${MSDK}/Examples/MAX32655/${BLE_FreeRTOS_OTA}/build/max32655.elf \
        -ex "set confirm off" \
        -ex "set architecture armv7e-m" \
        -ex "symbol-file ${MSDK}/Examples/MAX32655/${BLE_FreeRTOS_OTA}/build/max32655.elf" \
        -ex "target remote | ${OPENOCD_EXE} -c \"gdb_port pipe;\" -s ${OPENOCD}/scripts -f ${OPENOCD}/scripts/interface/cmsis-dap.cfg -f ${OPENOCD}/scripts/target/max32655.cfg -c \"cmsis_dap_serial ${DAP_SERIAL}\" -c \"init; reset halt\"" \
        -ex "load" \
        -ex "compare-section" \
        -ex "monitor resume" \
        --batch
}

function build_flash_bootloader_by_gdb
{
    printf "\n>>>>>> build Bootloader\n\n"
    cd ${MSDK}/Examples/MAX32655/Bootloader
    make MAXIM_PATH=${MSDK} distclean
    make MAXIM_PATH=${MSDK} BOARD=EvKit_V1 USE_INTERNAL_FLASH=1 -j8

    printf "\n>>>>>> flash Bootloader\n\n"
    ${GDB_DIR}/arm-none-eabi-gdb ${MSDK}/Examples/MAX32655/Bootloader/build/max32655.elf \
        -ex "set confirm off" \
        -ex "set architecture armv7e-m" \
        -ex "symbol-file ${MSDK}/Examples/MAX32655/Bootloader/build/max32655.elf" \
        -ex "target remote | ${OPENOCD_EXE} -c \"gdb_port pipe;\" -s ${OPENOCD}/scripts -f ${OPENOCD}/scripts/interface/cmsis-dap.cfg -f ${OPENOCD}/scripts/target/max32655.cfg -c \"cmsis_dap_serial ${DAP_SERIAL}\" -c \"init; reset halt\"" \
        -ex "load" \
        -ex "compare-section" \
        -ex "monitor resume" \
        --batch
}

#--------------------------------------------------------------------------------------------------

# Test 1: worked
#erase_flash
#build_flash_otas
#build_flash_bootloader
#verify_otas

# Test 2: failed
#erase_flash
#build_flash_bootloader
#verify_bootloader
#build_flash_otas
#verify_bootloader  # Failed ! Bootloader was wiped out.

# Test 3: worked
erase_flash
build_flash_otas_by_gdb
build_flash_bootloader_by_gdb

# Test 4: worked
#erase_flash
#build_flash_bootloader_by_gdb
#build_flash_otas_by_gdb

printf "\nDONE!"
