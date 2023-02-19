#!/usr/bin/env bash

echo
echo "#################################################################################################################"
echo "# ./local_full_per_test.sh 1_MSDK 2_CHIP_UC 3_BRD_TYPE 4_SHA                                                    #"
echo "# Example:                                                                                                      #"
echo "#     ./local_full_per_test.sh            \                                                                     #"
echo "#         ~/Workspace/temp/msdk-me18      \                                                                     #"
echo "#         MAX32690 WLP_V1 "" 2>&1 | tee test.log                                                                   #"
echo "#################################################################################################################"
echo
echo $0 $@
echo "Input argument number: $#"
echo

if [[ $# -ne 4 ]]; then
    echo "Invalid argument count."
    exit 1
fi

# Example:
# NOTE: The Tools/Bluetooth/ must be updated in msdk-me18.
# ./local_full_per_test.sh ~/Workspace/yc/msdk_open MAX32690 WLP_V1 "" 2>&1 | tee test.log
# ./local_full_per_test.sh ~/Workspace/msdk_open MAX32655 EvKit_V1 "" 2>&1 | tee test_32655.log

#----------------------------------------------------------------------------------------------------------------------
# Validate the input arguments
TEST_MSDK=$1
CHIP_UC=$2
BRD_TYPE=$3
SHA=$4

#----------------------------------------------------------------------------------------------------------------------
# Prepare the test repositories
echo "TEST_MSDK: ${TEST_MSDK}"
echo "  CHIP_UC: ${CHIP_UC}"
echo " BRD_TYPE: ${BRD_TYPE}"
echo "      SHA: ${SHA}"
echo ""

TEST_ROOT=`realpath ~/temp_safe_to_del`
#bash -x -c "rm -rf ${TEST_ROOT}"
mkdir -p ${TEST_ROOT}
bash -x -c "cp -Rp ${TEST_MSDK} ${TEST_ROOT}/msdk/"

MSDK=${TEST_ROOT}/msdk
echo "MSDK: ${MSDK}"
cd ${MSDK}
if [ "x${SHA}" != "x" ]; then
    base +x -c "git checkout ${SHA}"
    base +x -c "git status -u"
fi
echo

echo "Checkout the latest scripts from Tools/Bluetooth, .github/workflows"
ls -hal Tools/Bluetooth
bash +x -c "git checkout Tools/Bluetooth"
ls -hal Tools/Bluetooth
echo ""

echo "Checkout the latest scripts from .github/workflows"
ls -hal .github/workflows
#bash +x -c "git checkout .github/workflows"
ls -hal .github/workflows
echo ""

echo "Remove me !!!"
echo "cp -rp ~/Workspace/temp/msdk-me18/.github/ .github/"
#cp -rp ~/Workspace/temp/msdk-me18/.github/ .github/
echo ""

# This will be used to search the test used in the configuration json file.
TEST=local_full_per_test

cd ${TEST_ROOT}
echo PWD: `pwd`
echo ""

echo "Show the contents of the test folder."
tree -a -L 2
echo ""

#----------------------------------------------------------------------------------------------------------------------
# Get the configuration
CONFIG_FILE=/home/$USER/Workspace/ci_config/msdk.json
echo CONFIG_FILE: ${CONFIG_FILE}
echo "cat ${CONFIG_FILE}"
cat ${CONFIG_FILE}
echo

NO_SKIP=`python3 -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['tests']['${TEST}']['no_skip'])"`
echo "::set-env name=NO_SKIP::${NO_SKIP}"
echo "NO_SKIP: ${NO_SKIP}"
echo ""

LIMIT=`python3 -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['tests']['${TEST}']['limit'])"`
echo "::set-env name=LIMIT::${LIMIT}"
echo "LIMIT: ${LIMIT}"
echo ""

DO_MAX32655=$(python3     -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['tests']['${TEST}']['do_max32655'])")
DO_MAX32665=$(python3     -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['tests']['${TEST}']['do_max32665'])")
DO_MAX32690=$(python3     -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['tests']['${TEST}']['do_max32690'])")
DO_MAX32690_WLP=$(python3 -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['tests']['${TEST}']['do_max32690_wlp'])")
echo "::set-env name=DO_MAX32655::${DO_MAX32655}"
echo "::set-env name=DO_MAX32665::${DO_MAX32665}"
echo "::set-env name=DO_MAX32690::${DO_MAX32690}"
echo "::set-env name=DO_MAX32690_WLP::${DO_MAX32690_WLP}"
echo DO_MAX32655: ${DO_MAX32655}
echo DO_MAX32665: ${DO_MAX32665}
echo DO_MAX32690: ${DO_MAX32690}
echo DO_MAX32690_WLP: ${DO_MAX32690_WLP}
echo ""

MAX32655_PKG_RA=$(python3     -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['tests']['${TEST}']['max32655_pkglen_range'])")
MAX32665_PKG_RA=$(python3     -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['tests']['${TEST}']['max32665_pkglen_range'])")
MAX32690_PKG_RA=$(python3     -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['tests']['${TEST}']['max32690_pkglen_range'])")
MAX32690_WLP_PKG_RA=$(python3 -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['tests']['${TEST}']['max32690_wlp_pkglen_range'])")
echo "::set-env name=MAX32655_PKG_RA::${MAX32655_PKG_RA}"
echo "::set-env name=MAX32665_PKG_RA::${MAX32665_PKG_RA}"
echo "::set-env name=MAX32690_PKG_RA::${MAX32690_PKG_RA}"
echo "::set-env name=MAX32690_WLP_PKG_RA::${MAX32690_WLP_PKG_RA}"
echo MAX32655_PKG_RA: ${MAX32655_PKG_RA}
echo MAX32665_PKG_RA: ${MAX32665_PKG_RA}
echo MAX32690_PKG_RA: ${MAX32690_PKG_RA}
echo MAX32690_WLP_PKG_RA: ${MAX32690_WLP_PKG_RA}
echo ""

export MAX32655_PHY_RA=$(python3     -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['tests']['${TEST}']['max32655_phy_range'])")
export MAX32665_PHY_RA=$(python3     -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['tests']['${TEST}']['max32665_phy_range'])")
export MAX32690_PHY_RA=$(python3     -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['tests']['${TEST}']['max32690_phy_range'])")
export MAX32690_WLP_PHY_RA=$(python3 -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['tests']['${TEST}']['max32690_wlp_phy_range'])")
echo "::set-env name=MAX32655_PHY_RA::${MAX32655_PHY_RA}"
echo "::set-env name=MAX32665_PHY_RA::${MAX32665_PHY_RA}"
echo "::set-env name=MAX32690_PHY_RA::${MAX32690_PHY_RA}"
echo "::set-env name=MAX32690_WLP_PHY_RA::${MAX32690_WLP_PHY_RA}"
echo MAX32655_PHY_RA: ${MAX32655_PHY_RA}
echo MAX32665_PHY_RA: ${MAX32665_PHY_RA}
echo MAX32690_PHY_RA: ${MAX32690_PHY_RA}
echo MAX32690_WLP_PHY_RA: ${MAX32690_WLP_PHY_RA}
echo ""

MAX32655_ATTENS=$(python3     -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['tests']['simple_per_test.yml']['max32655_attens'])")
MAX32665_ATTENS=$(python3     -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['tests']['simple_per_test.yml']['max32665_attens'])")
MAX32690_ATTENS=$(python3     -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['tests']['simple_per_test.yml']['max32690_attens'])")
MAX32690_WLP_ATTENS=$(python3 -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['tests']['simple_per_test.yml']['max32690_attens'])")
echo "::set-env name=MAX32655_ATTENS::${MAX32655_ATTENS}"
echo "::set-env name=MAX32665_ATTENS::${MAX32665_ATTENS}"
echo "::set-env name=MAX32690_ATTENS::${MAX32690_ATTENS}"
echo "::set-env name=MAX32690_WLP_ATTENS::${MAX32690_WLP_ATTENS}"
echo MAX32655_ATTENS: ${MAX32655_ATTENS}
echo MAX32665_ATTENS: ${MAX32665_ATTENS}
echo MAX32690_ATTENS: ${MAX32690_ATTENS}
echo MAX32690_WLP_ATTENS: ${MAX32690_WLP_ATTENS}
echo 

MAX32655_STEP=$(python3     -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['tests']['${TEST}']['max32655_step'])")
MAX32665_STEP=$(python3     -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['tests']['${TEST}']['max32665_step'])")
MAX32690_STEP=$(python3     -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['tests']['${TEST}']['max32690_step'])")
MAX32690_WLP_STEP=$(python3 -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['tests']['${TEST}']['max32690_wlp_step'])")
echo "::set-env name=MAX32655_STEP::${MAX32655_STEP}"
echo "::set-env name=MAX32665_STEP::${MAX32665_STEP}"
echo "::set-env name=MAX32690_STEP::${MAX32690_STEP}"
echo "::set-env name=MAX32690_WLP_STEP::${MAX32690_WLP_STEP}"
echo MAX32655_STEP: ${MAX32655_STEP}
echo MAX32665_STEP: ${MAX32665_STEP}
echo MAX32690_STEP: ${MAX32690_STEP}
echo MAX32690_WLP_STEP: ${MAX32690_WLP_STEP}
echo ""

JOB_CURR_TIME=$(date +%Y-%m-%d_%H-%M-%S)
echo "::set-env name=JOB_CURR_TIME::${JOB_CURR_TIME}"
echo ""

echo "::set-env name=MSDK::${MSDK}"
echo ""

RETRY=$(python3     -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['tests']['simple_per_test.yml']['retry_limit'])")
echo "::set-env name=RETRY::${RETRY}"

#----------------------------------------------------------------------------------------------------------------------
# Prepare the arguments for script.                    
$MSDK/.github/workflows/scripts/msdk_per_skip_check.sh \
    $NO_SKIP \
    $MSDK    \
    $CHIP_UC \
    $BRD_TYPE

if [[ $? -ne 0 ]]; then
    echo "SKIPPED."
    exit 0
fi

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

CURR_TIME=$(date +%Y-%m-%d_%H-%M-%S)
CURR_JOB_FILE=/home/$USER/Workspace/Resource_Share/History/msdk_simple_per_test_${CURR_TIME}_${BRD2_CHIP_LC}.txt
echo "::set-env name=CURR_JOB_FILE::${CURR_JOB_FILE}"
CURR_LOG=/home/$USER/Workspace/Resource_Share/Logs/msdk_simple_per_test_${CURR_TIME}_${BRD2_CHIP_LC}.log          
echo "::set-env name=CURR_LOG::${CURR_LOG}"
RESULT_PATH=~/Workspace/ci_results/per
res=${RESULT_PATH}/msdk-${CURR_TIME}
all_in_one=${res}_${BRD2_CHIP_LC}_${BRD2_TYPE}.csv
echo "::set-env name=all_in_one::${all_in_one}"

#------------------------------------------------
${MSDK}/.github/workflows/scripts/board_per_test.sh \
    $MSDK      \
    $BRD1      \
    $BRD2      \
    $CURR_TIME \
    $(realpath ${CURR_JOB_FILE}) \
    $(realpath ${CURR_LOG})      \
    $(realpath ${all_in_one})    \
    "${MAX32655_PKG_RA}"         \
    "${MAX32655_PHY_RA}"         \
    ${MAX32655_STEP}             \
    ${LIMIT}                     \
    ${RETRY}                     \
    ${MAX32655_ATTENS}           \
    2>&1 | tee -a ${CURR_LOG}

if [[ $? -ne 0 ]]; then
    exit 1
fi

cd ${MSDK}
echo PWD: `pwd`
echo
chmod u+x ${MSDK}/.github/workflows/scripts/unlock_plot.sh
${MSDK}/.github/workflows/scripts/unlock_plot.sh ${MSDK} ${CURR_JOB_FILE} ${all_in_one} True 2>&1 | tee -a ${CURR_LOG}
