#!/usr/bin/env bash

echo
echo "#################################################################################################################"
echo "# setup_test_env.sh 1TEST_ROOT
echo "#################################################################################################################"
echo
echo $0 $@
echo

TEST_ROOT=$1

echo "TEST_ROOT:" ${TEST_ROOT}
echo

CONFIG_FILE=~/Workspace/ci_config/RF-PHY-closed.json
CI_TEST=simple_per.yml

echo "cat ${CONFIG_FILE}"
cat ${CONFIG_FILE}
echo

NO_SKIP=`python3 -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['tests']['${CI_TEST}']['no_skip'])"`
echo "NO_SKIP: ${NO_SKIP}"

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

#<<<
if [ 1 -eq 2 ]; then
RUN_TEST=0
for ((i=0; i<DUT_num; i++))
do
    CHIP_UC=${DUTs[$i,0]}
    BRD_TYPE=${DUTs[$i,1]}
    echo
    echo "#------------------------------------------------------------------------------------------------------------"
    echo "# Check ${CHIP_UC} ${BRD_TYPE}"
    echo "#------------------------------------------------------------------------------------------------------------"
    echo
    bash $MSDK/Libraries/RF-PHY-closed/.github/workflows/scripts/rf_phy_per_skip_check.sh \
        $NO_SKIP \
        $MSDK    \
        $CHIP_UC \
        $BRD_TYPE

    if [[ $? -eq 0 ]]; then
        RUN_TEST=1
        echo "Test is required."
        break
    fi
done

echo "RUN_TEST=$RUN_TEST" >> $GITHUB_OUTPUT

if [ ${RUN_TEST} -eq 0 ]; then
    echo "No test is required."
    exit 1
fi
fi
#>>>

CONFIG_FILE=~/Workspace/ci_config/RF-PHY-closed.json
CI_TEST=simple_per.yml

echo
echo "#------------------------------------------------------------------------------------------------------"
echo "# Check which repo and version to  use."
echo "#------------------------------------------------------------------------------------------------------"
echo
# By default the used repository is the msdk main branch. For testing purpose, it can
# be changed according to the configuration file.
USED_REPO=`python3 -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['tests']['${CI_TEST}']['repo'])"`
echo "USED_REPO: ${USED_REPO}"
COMMIT_ID=`python3 -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['tests']['${CI_TEST}']['commit_id'])"`
echo "COMMIT_ID: ${COMMIT_ID}"
echo

set -x
if [ "x${USED_REPO}" == "x" ] || [ "x${COMMIT_ID}" == "x" ]; then
    echo "use default repo main branch"
    mkdir -p ${TEST_ROOT}
    cd ${TEST_ROOT}
    git clone https://github.com/Analog-Devices-MSDK/msdk.git
    cd ${TEST_ROOT}/msdk/Libraries
    git clone https://github.com/Analog-Devices-MSDK/RF-PHY-closed.git
else
    mkdir -p ${TEST_ROOT}
    cd ${TEST_ROOT}
    git clone ${USED_REPO} msdk
    cd ${TEST_ROOT}/msdk
    git checkout ${COMMIT_ID}
fi
set +x

echo
echo "#------------------------------------------------------------------------------------------------------"
echo "# Check if need to change the RF-PHY-closed repo."
echo "#------------------------------------------------------------------------------------------------------"
echo

NEW_RF_PHY_REPO=`python3 -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['tests']['${CI_TEST}']['rf_phy_repo'])"`
echo " NEW_RF_PHY_REPO: ${NEW_RF_PHY_REPO}"
RF_PHY_COMMIT_ID=`python3 -c "import json; import os; obj=json.load(open('${CONFIG_FILE}')); print(obj['tests']['${CI_TEST}']['rf_phy_commit_id'])"`
echo "RF_PHY_COMMIT_ID: ${RF_PHY_COMMIT_ID}"
echo
if [ "x${NEW_RF_PHY_REPO}" != "x" ] && [ "x${RF_PHY_COMMIT_ID}" != "x" ]; then
    set -x
    echo "save the ci test using scripts"
    TEMP_DIR=/tmp/msdk/ci/per/${JOB_CURR_TIME}
    mkdir -p ${TEMP_DIR}
    mv ${MSDK}/Libraries/RF-PHY-closed/.github/workflows/scripts ${TEMP_DIR}/RF_PHY_scripts
    rm -rf ${MSDK}/Libraries/RF-PHY-closed
    cd ${MSDK}/Libraries
    git clone ${NEW_RF_PHY_REPO} RF-PHY-closed
    cd ${MSDK}/Libraries/RF-PHY-closed
    git checkout ${RF_PHY_COMMIT_ID}
    echo "restore the scripts"
    rm -rf ${MSDK}/Libraries/RF-PHY-closed/.github/workflows/scripts
    mv ${TEMP_DIR}/RF_PHY_scripts ${MSDK}/Libraries/RF-PHY-closed/.github/workflows/scripts
    git status -u
    set +x
fi

echo
echo "$0: DONE!"
echo
