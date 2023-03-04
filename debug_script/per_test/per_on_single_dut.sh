#!/usr/bin/env bash

echo
echo "#################################################################################################################"
echo "# ./per_on_single_dut.sh 1CHIP_UC 2BRD_TYPE 3DOWNLOAD 4JOB_TIME                                                 #"
echo "# Example:                                                                                                      #"
echo "#     ./per_on_single_dut.sh MAX32655 EvKit_V1 False 2023-02-20_17-13-45 2>&1 | tee test.log                    #"
echo "#################################################################################################################"
echo
echo $0 $@
echo "Input argument number: $#"
echo

if [[ $# -ne 4 ]]; then
    echo "Invalid argument count."
    exit 1
fi

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# NOTE:
#    ~/Workspace/ci_config/msdk.json must be correctly modified for this test.
#    Tools/Bluetooth must be matched with the checkout version.
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

#----------------------------------------------------------------------------------------------------------------------
# Validate the input arguments
CHIP_UC=$1
BRD_TYPE=$2
DOWNLOAD=$3
JOB_CURR_TIME=$4

echo "     DUT CHIP: ${CHIP_UC}"
echo "   Board type: ${BRD_TYPE}"
echo "     Download: ${DOWNLOAD}"
echo "JOB_CURR_TIME: ${JOB_CURR_TIME}"
echo

#----------------------------------------------------------------------------------------------------------------------
# Get the configuration
CONFIG_FILE=~/Workspace/ci_config/RF-PHY-closed.json
CI_TEST=local_full_per_test
echo "CI_TEST:" $CI_TEST
echo

REPO=`python3 -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['tests']['${CI_TEST}']['repo'])"`
echo "REPO: ${REPO}"
echo ""

NO_SKIP=`python3 -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['tests']['${CI_TEST}']['no_skip'])"`
echo "NO_SKIP: ${NO_SKIP}"
echo ""

COMMIT_ID=`python3 -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['tests']['${CI_TEST}']['commit_id'])"`
echo "COMMIT_ID: ${COMMIT_ID}"
echo ""

START_TIME=`python3 -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['tests']['${CI_TEST}']['start_time'])"`
echo "START_TIME: ${START_TIME}"
echo ""

LIMIT=`python3 -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['tests']['${CI_TEST}']['limit'])"`
echo "LIMIT: ${LIMIT}"
echo ""

DO_MAX32655=$(python3     -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['tests']['${CI_TEST}']['do_max32655'])")
DO_MAX32665=$(python3     -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['tests']['${CI_TEST}']['do_max32665'])")
DO_MAX32690=$(python3     -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['tests']['${CI_TEST}']['do_max32690'])")
DO_MAX32690_WLP=$(python3 -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['tests']['${CI_TEST}']['do_max32690_wlp'])")
echo DO_MAX32655: ${DO_MAX32655}
echo DO_MAX32665: ${DO_MAX32665}
echo DO_MAX32690: ${DO_MAX32690}
echo DO_MAX32690_WLP: ${DO_MAX32690_WLP}
echo ""

MAX32655_PKG_RA=$(python3     -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['tests']['${CI_TEST}']['max32655_pkglen_range'])")
MAX32665_PKG_RA=$(python3     -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['tests']['${CI_TEST}']['max32665_pkglen_range'])")
MAX32690_PKG_RA=$(python3     -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['tests']['${CI_TEST}']['max32690_pkglen_range'])")
MAX32690_WLP_PKG_RA=$(python3 -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['tests']['${CI_TEST}']['max32690_wlp_pkglen_range'])")
echo MAX32655_PKG_RA: ${MAX32655_PKG_RA}
echo MAX32665_PKG_RA: ${MAX32665_PKG_RA}
echo MAX32690_PKG_RA: ${MAX32690_PKG_RA}
echo MAX32690_WLP_PKG_RA: ${MAX32690_WLP_PKG_RA}
echo

export MAX32655_PHY_RA=$(python3     -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['tests']['${CI_TEST}']['max32655_phy_range'])")
export MAX32665_PHY_RA=$(python3     -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['tests']['${CI_TEST}']['max32665_phy_range'])")
export MAX32690_PHY_RA=$(python3     -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['tests']['${CI_TEST}']['max32690_phy_range'])")
export MAX32690_WLP_PHY_RA=$(python3 -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['tests']['${CI_TEST}']['max32690_wlp_phy_range'])")
echo MAX32655_PHY_RA: ${MAX32655_PHY_RA}
echo MAX32665_PHY_RA: ${MAX32665_PHY_RA}
echo MAX32690_PHY_RA: ${MAX32690_PHY_RA}
echo MAX32690_WLP_PHY_RA: ${MAX32690_WLP_PHY_RA}
echo

MAX32655_ATTENS=$(python3     -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['tests']['${CI_TEST}']['max32655_attens'])")
MAX32665_ATTENS=$(python3     -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['tests']['${CI_TEST}']['max32665_attens'])")
MAX32690_ATTENS=$(python3     -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['tests']['${CI_TEST}']['max32690_attens'])")
MAX32690_WLP_ATTENS=$(python3 -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['tests']['${CI_TEST}']['max32690_wlp_attens'])")
echo MAX32655_ATTENS: ${MAX32655_ATTENS}
echo MAX32665_ATTENS: ${MAX32665_ATTENS}
echo MAX32690_ATTENS: ${MAX32690_ATTENS}
echo MAX32690_WLP_ATTENS: ${MAX32690_WLP_ATTENS}
echo 

MAX32655_STEP=$(python3     -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['tests']['${CI_TEST}']['max32655_step'])")
MAX32665_STEP=$(python3     -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['tests']['${CI_TEST}']['max32665_step'])")
MAX32690_STEP=$(python3     -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['tests']['${CI_TEST}']['max32690_step'])")
MAX32690_WLP_STEP=$(python3 -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['tests']['${CI_TEST}']['max32690_wlp_step'])")
echo MAX32655_STEP: ${MAX32655_STEP}
echo MAX32665_STEP: ${MAX32665_STEP}
echo MAX32690_STEP: ${MAX32690_STEP}
echo MAX32690_WLP_STEP: ${MAX32690_WLP_STEP}
echo

echo "JOB_CURR_TIME: ${JOB_CURR_TIME}"
echo

RETRY=$(python3     -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['tests']['${CI_TEST}']['retry_limit'])")
echo RETRY: ${RETRY}
echo

#----------------------------------------------------------------------------------------------------------------------
TEST_ROOT=`realpath ~/temp_safe_to_del`

if [ "${DOWNLOAD,,}" == "true" ]; then
    bash -x -c "rm -rf ${TEST_ROOT}/msdk"
    bash -x -c "mkdir -p ${TEST_ROOT}"
    cd ${TEST_ROOT}

    if [ "x${REPO}" == "x" ]; then
	    REPO=git@github.com:yc-adi/msdk_open.git
    fi

    git clone ${REPO} ${TEST_ROOT}/msdk
    cd ${TEST_ROOT}/msdk
    git checkout dev-rf-phy-per
else
    echo "Keep using the current contents in the folder: ${TEST_ROOT}"
    bash -x -c "rm ${MSDK}/msdk/*.zip"
fi

MSDK=${TEST_ROOT}/msdk
echo "MSDK: ${MSDK}"
cd ${MSDK}
echo PWD: `pwd`

if [ "x${COMMIT_ID}" != "x" ]; then
    bash -x -c "git checkout ${COMMIT_ID}"
    echo
fi

bash -x -c "git status -u"
echo

#echo "Checkout the latest scripts from Tools/Bluetooth"
#ls -hal Tools/Bluetooth
#echo
#git checkout Tools/Bluetooth
#echo
#ls -hal Tools/Bluetooth
#echo

#echo "Checkout the latest scripts from .github/workflows"
#ls -hal .github/workflows
#echo
#git checkout .github/workflows
#echo
#ls -hal .github/workflows
#echo

#echo "Remove me !!!"
#echo "cp -rp ~/Workspace/temp/msdk-me18/.github/ .github/"
#cp -rp ~/Workspace/temp/msdk-me18/.github/ .github/
echo ""

#----------------------------------------------------------------------------------------------------------------------
# prepare RF-PHY-closed
if [ ! -d ~/temp_safe_to_del/msdk/Libraries/RF-PHY-closed ]; then
    cd ~/temp_safe_to_del/msdk/Libraries
    git clone git@github.com:yc-adi/RF-PHY-closed-yc RF-PHY-closed
fi
# This will be used to search the test used in the configuration json file.
cd ${TEST_ROOT}
echo PWD: `pwd`
echo ""

#echo "Show the contents of the test folder."
#tree -a -L 2
#echo ""

#----------------------------------------------------------------------------------------------------------------------
# Prepare the arguments for script.                    
bash $MSDK/Libraries/RF-PHY-closed/.github/workflows/scripts/rf_phy_per_skip_check.sh \
    $NO_SKIP \
    $MSDK    \
    $CHIP_UC \
    $BRD_TYPE \
    $JOB_CURR_TIME

#if [ ! -f ${MSDK}/${CHIP_UC}_${BRD_TIME}_${JOB_CURR_TIME}.do ]; then
#    echo "SKIPPED."
#    exit 0
#else
#    echo "Test this ${CHIP_UC}"
#fi

#------------------------------------------------
# Prepare the arguments for function call
BRD2_TYPE=EvKit_V1
NEW_NAME=DO_${CHIP_UC}
chip_and_board_type=${CHIP_UC,,}
if [ "${CHIP_UC}" == "MAX32690" ] && [ "${BRD_TYPE}" == "WLP_V1" ]; then
    BRD2_TYPE=WLP_V1    
    NEW_NAME=DO_${CHIP_UC}_WLP
    chip_and_board_type=${CHIP_UC,,}_wlp
fi

BRD1=`python3 -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['used_boards']['$(hostname)']['${chip_and_board_type}'][0])"`
BRD2=`python3 -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['used_boards']['$(hostname)']['${chip_and_board_type}'][1])"`

echo BRD1: ${BRD1}
echo BRD2: ${BRD2}
BRD2_CHIP_LC=${CHIP_UC,,}
echo ""

DO_IT=${!NEW_NAME}
echo DO_IT: ${DO_IT}
if [ "${DO_IT}" == "0" ]; then
    echo "Skip the test for ${CHIP_UC} ${BRD_TYPE}."
    exit 0
fi

if [ ${CHIP_UC} == "MAX32655" ]; then
    PKG_RA=${MAX32655_PKG_RA}
    PHY_RA=${MAX32655_PHY_RA}
    STEP=${MAX32655_STEP}
    ATTENS=${MAX32655_ATTENS}
elif [ ${CHIP_UC} == "MAX32665" ]; then
    PKG_RA=${MAX32665_PKG_RA}
    PHY_RA=${MAX32665_PHY_RA}
    STEP=${MAX32665_STEP}
    ATTENS=${MAX32665_ATTENS}
elif [ ${CHIP_UC} == "MAX32690" ] && [ ${BRD_TYPE} == "EvKit_V1" ]; then
    PKG_RA=${MAX32690_PKG_RA}
    PHY_RA=${MAX32690_PHY_RA}
    STEP=${MAX32690_STEP}
    ATTENS=${MAX32690_ATTENS}
else
    PKG_RA=${MAX32690_WLP_PKG_RA}
    PHY_RA=${MAX32690_WLP_PHY_RA}
    STEP=${MAX32690_WLP_STEP}
    ATTENS=${MAX32690_WLP_ATTENS}
fi

CURR_TIME=$(date +%Y-%m-%d_%H-%M-%S)

CURR_JOB_FILE=~/Workspace/Resource_Share/Logs/local-full-per-test-${CURR_TIME}_${BRD2_CHIP_LC}.txt
     CURR_LOG=~/Workspace/Resource_Share/Logs/local-full-per-test-${CURR_TIME}_${BRD2_CHIP_LC}.log

RESULT_PATH=~/Workspace/ci_results/per
res=${RESULT_PATH}/local-full-per-test-${CURR_TIME}
all_in_one=${res}_${BRD2_CHIP_LC}_${BRD2_TYPE}.csv
echo "all_in_one:" $all_in_one
echo

#----------------------------------------------------------------------------------------------------------------------
${MSDK}/Libraries/RF-PHY-closed/.github/workflows/scripts/RF-PHY_board_per_test.sh \
    $MSDK      \
    $BRD1      \
    $BRD2      \
    $CURR_TIME \
    $(realpath ${CURR_JOB_FILE}) \
    $(realpath ${CURR_LOG})      \
    $(realpath ${all_in_one})    \
    "${PKG_RA}"         \
    "${PHY_RA}"         \
    ${STEP}             \
    ${LIMIT}                     \
    ${RETRY}                     \
    "${ATTENS}"                  \
    "${CI_TEST}"
    2>&1 | tee -a ${CURR_LOG}

if [[ $? -ne 0 ]]; then
    exit 1
fi

#----------------------------------------------------------------------------------------------------------------------
# unlock and plot the results
cd ${MSDK}
echo PWD: `pwd`
echo

chmod u+x ${MSDK}/.github/workflows/scripts/unlock_plot.sh
echo ${MSDK}/.github/workflows/scripts/unlock_plot.sh ${MSDK} "${CURR_JOB_FILE}" "${all_in_one}" True ${JOB_CURR_TIME}
${MSDK}/.github/workflows/scripts/unlock_plot.sh      ${MSDK} "${CURR_JOB_FILE}" "${all_in_one}" True ${JOB_CURR_TIME}

