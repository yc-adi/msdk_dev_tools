#!/usr/bin/env bash

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# NOTE:
#    ~/Workspace/ci_config/RF-PHY-closed.json must be correctly modified for this test.
#    The configuration used test name: local_full_per_test
#    Tools/Bluetooth must be matched with the checkout version.
#
#    The test root folder is at ~/temp_safe_to_del
#    Option 1: DOWNLOAD 0, manually prepare msdk and RF-PHY-closed in the root folder
#    Option 2: DONWLOAD 1, use configuration to set up the repos
#
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

echo
echo "#################################################################################################################"
echo "# ./local_full_per_test.sh 1_TOTAL_TEST 2_DOWNLOAD                                                                #"
echo "#################################################################################################################"
echo
echo $0 $@
echo "Input argument number: $#"
echo

if [ $# -ne 2 ]; then
    echo "invalid arguments"
    exit 1
fi

TOTAL_TEST=$1
DOWNLOAD=$2

echo "TOTAL_TEST:" $TOTAL_TEST
echo "  DONWLOAD:" $DOWNLOAD
echo

# per_on_single_dut.sh 1CHIP_UC 2BRD_TYPE 3DOWNLOAD 4JOB_TIME

declare -A DUTs
DUT_num=4
DUTs[0,0]=MAX32655
DUTs[0,1]=EvKit_V1
DUTs[1,0]=MAX32665
DUTs[1,1]=EvKit_V1
DUTs[2,0]=MAX32690
DUTs[2,1]=EvKit_V1
DUTs[3,0]=MAX32690
DUTs[3,1]=WLP_V1

WHAT_TESTED=~/temp_safe_to_del/$Tested_$(date +%Y-%m-%d_%H-%M-%S).log
echo "WHAT_TESTED:" $WHAT_TESTED
touch $WHAT_TESTED
echo

for ((test_cnt=1; test_cnt<=TOTAL_TEST; test_cnt++))
do
    echo "#------------------------------------------------------------------------------------------------------------"
    echo "# TEST: ${test_cnt}"
    echo "#------------------------------------------------------------------------------------------------------------"
    echo

    JOB_CURR_TIME=$(date +%Y-%m-%d_%H-%M-%S)
    echo "JOB_CURR_TIME": $JOB_CURR_TIME
    echo $JOB_CURR_TIME >> $WHAT_TESTED
    echo

    for ((i=0; i<DUT_num; i++))
    do
        CHIP_UC=${DUTs[$i,0]}
        BRD_TYPE=${DUTs[$i,1]}
        echo "# -------------------------------------------------------------------------------------------------------"
        echo "# ./per_on_single_dut.sh ${CHIP_UC} ${BRD_TYPE} ${DOWNLOAD} ${JOB_CURR_TIME}"
        echo "#--------------------------------------------------------------------------------------------------------"
        ./per_on_single_dut.sh ${CHIP_UC} ${BRD_TYPE} ${DOWNLOAD} ${JOB_CURR_TIME}
        echo
    done

    echo "#------------------------------------------------------------------------------------------------------------"
    echo "# TEST: ${test_cnt} finished."
    echo "#------------------------------------------------------------------------------------------------------------"
    echo
done
