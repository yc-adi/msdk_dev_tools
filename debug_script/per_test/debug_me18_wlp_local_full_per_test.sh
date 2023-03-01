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
echo "# ./local_full_per_test.sh 1_TOTAL_TEST 2_DOWNLOAD 3_SHA 4_CHANGE_REPO                                                               #"
echo "#################################################################################################################"
echo
echo $0 $@
echo "Input argument number: $#"
echo

if [ $# -ne 4 ]; then
    echo "invalid arguments"
    exit 1
fi

TOTAL_TEST=$1
DOWNLOAD=$2

echo "TOTAL_TEST:" $TOTAL_TEST
echo "  DONWLOAD:" $DOWNLOAD
echo $3
MANIPULATE_REPO=$4
echo "MANIPULATE_REPO": $4

#-------------------------------------------------------------------------------------------------------------------
if [ "$MANIPULATE_REPO" == "1" ]; then
    echo "For ME18 WLP debug"

    set -x

    test_dir=`pwd`
    echo $test_dir

    rm ~/temp_safe_to_del/msdk/*.elf

    rm -rf ~/temp_safe_to_del/msdk/.github
    rm -rf ~/temp_safe_to_del/msdk/Tools/Bluetooth
    rm -rf ~/temp_safe_to_del/msdk/Libraries/RF-PHY-closed/.github

    cd ~/temp_safe_to_del/msdk

    rm -rf Libraries/BlePhy
    echo
    rm -rf Examples/MAX32690/BLE5_ctr
    echo

    git checkout -- .

    git checkout main 1>/dev/null
    git checkout -- .
    echo

    git checkout $3
    git status
    git checkout -- .
    git status
    echo

    rm -rf ~/temp_safe_to_del/msdk/.github
    rm -rf ~/temp_safe_to_del/msdk/Tools/Bluetooth
    rm -rf ~/temp_safe_to_del/msdk/Libraries/RF-PHY-closed/.github

    cp -rp ~/temp_safe_to_del/saved/Bluetooth ~/temp_safe_to_del/msdk/Tools/
    cp -rp ~/temp_safe_to_del/saved/github    ~/temp_safe_to_del/msdk/.github/
    cp -rp ~/temp_safe_to_del/saved/RF_github ~/temp_safe_to_del/msdk/Libraries/RF-PHY-closed/.github/

    sed -i "s/TRACE = 0/TRACE = 2/g" ~/temp_safe_to_del/msdk/Examples/MAX32690/BLE5_ctr/project.mk || true

    cd $test_dir

    set +x
fi

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

    for ((i=3; i<DUT_num; i++))
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
