#!/usr/bin/env bash

echo
echo "#################################################################################################################"
echo "# ./local_full_per_test.sh 1_MSDK 2_DEV_TOOLS 3_PER_TOOL 4_CHIP_UC                                              #"
echo "# Example:                                                                                                      #"
echo "#     ./local_full_per_test.sh            \                                                                     #"
echo "#         ~/Workspace/temp/msdk-me18      \                                                                     #"
echo "#         ~/Workspace/yc/msdk_dev_tools   \                                                                     #"
echo "#         ~/Workspace/yc/msdk_ci_per_tool \                                                                     #"
echo "#         MAX32655 2>&1 | tee test.log                                                                          #"
echo "#################################################################################################################"
echo
echo $0 $@
echo

#----------------------------------------------------------------------------------------------------------------------
# Validate the input arguments
TEST_MSDK=$1
MSDK_DEV_TOOLS=$2
PER_TOOL=$3
CHIP_UC=$4

#----------------------------------------------------------------------------------------------------------------------
# Prepare the test repositories
echo "     TEST_MSDK: ${TEST_MSDK}"
echo "MSDK_DEV_TOOLS: ${MSDK_DEV_TOOLS}"
echo "      PER_TOOL: ${PER_TOOL}"
echo "       CHIP_UC: ${CHIP_UC}"
echo ""

TEST_ROOT=`realpath ~/temp_safe_to_del`

rm -rf ${TEST_ROOT}
mkdir -p ${TEST_ROOT}

cp -Rp ${TEST_MSDK}      ${TEST_ROOT}/msdk/
cp -Rp ${MSDK_DEV_TOOLS} ${TEST_ROOT}/msdk/
cp -Rp ${PER_TOOL}       ${TEST_ROOT}/msdk/

MSDK=${TEST_ROOT}/msdk

TEST=local_full_per_test

cd ${TEST_ROOT}
echo PWD: `pwd`
echo ""

echo "Show the PWD folder."
tree -a -L 2
echo ""
#----------------------------------------------------------------------------------------------------------------------
# Get the configuration
CONFIG_FILE=/home/$USER/Workspace/ci_config/RF-PHY-closed.json
echo CONFIG_FILE: ${CONFIG_FILE}
echo ""

NO_SKIP=`python3 -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['tests']['${TEST}']['no_skip'])"`
echo "::set-env name=NO_SKIP::${NO_SKIP}"
echo "NO_SKIP: ${NO_SKIP}"
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
echo
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
echo
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
echo

#----------------------------------------------------------------------------------------------------------------------
# Prepare the arguments for script.                    
#MSDK=TODO
#CHIP_UC=TODO
$MSDK/msdk_dev_tools/scripts/msdk_per_skip_check.sh \
    $NO_SKIP \
    $MSDK    \
    $CHIP_UC
if [[ $? -ne 0 ]]; then
    echo "SKIPPED."
    exit 0
fi
#------------------------------------------------
# Prepare the arguments for function call
NEW_NAME=DO_${CHIP_UC}
DO_IT=${!NEW_NAME}
echo DO_IT: ${DO_IT}
if [ "${DO_IT}" == "0" ]; then
    echo "Skip the test for MAX32655."
    exit 0
fi

BRD2_CHIP_LC=${CHIP_UC}
BRD1=nRF52840_1

if [ "${CHIP_UC}" == "MAX32655" ]; then
    BRD2=max32655_board_2
elif [ "${CHIP_UC}" == "MAX32665" ]; then
    BRD2=max32665_board_w3
elif [ "${CHIP_UC}" == "MAX32690" ]; then
    BRD2=max32690_board_w2
fi
echo BRD2: ${BRD2}
echo ""

CURR_TIME=$(date +%Y-%m-%d_%H-%M-%S)
CURR_JOB_FILE=/home/$USER/Workspace/Resource_Share/History/msdk_simple_per_test_${CURR_TIME}_${BRD2_CHIP_LC}.txt
echo "::set-env name=CURR_JOB_FILE::${CURR_JOB_FILE}"
CURR_LOG=/home/$USER/Workspace/Resource_Share/Logs/msdk_simple_per_test_${CURR_TIME}_${BRD2_CHIP_LC}.log          
echo "::set-env name=CURR_LOG::${CURR_LOG}"
RESULT_PATH=~/Workspace/ci_results/per
res=${RESULT_PATH}/msdk-${CURR_TIME}
all_in_one=${res}_${BRD2_CHIP_LC}.csv
echo "::set-env name=all_in_one::${all_in_one}"

#------------------------------------------------
${MSDK}/msdk_dev_tools/scripts/board_per_test.sh \
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
    2>&1 | tee -a ${CURR_LOG}

if [[ $? -ne 0 ]]; then
    exit 1
fi

cd ${MSDK}
echo PWD: `pwd`
echo
chmod u+x ${MSDK}/msdk_dev_tools/scripts/unlock_plot.sh
${MSDK}/msdk_dev_tools/scripts/unlock_plot.sh ${MSDK} ${CURR_JOB_FILE} ${all_in_one} True 2>&1 | tee -a ${CURR_LOG}
