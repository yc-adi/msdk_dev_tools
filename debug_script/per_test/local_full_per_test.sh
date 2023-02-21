#!/usr/bin/env bash

echo
echo "#################################################################################################################"
echo "# ./local_full_per_test.sh                                                                                      #"
echo "#################################################################################################################"
echo
echo $0 $@
echo "Input argument number: $#"
echo

JOB_CURR_TIME=$(date +%Y-%m-%d_%H-%M-%S)

echo "----------------------------------------------------------------------------------------------------------------_"
bash -x -c "./per_on_single_dut.sh MAX32655 EvKit_V1 False ${JOB_CURR_TIME}"
echo "----------------------------------------------------------------------------------------------------------------_"
echo 

echo "----------------------------------------------------------------------------------------------------------------_"
bash -x -c "./per_on_single_dut.sh MAX32665 EvKit_V1 False ${JOB_CURR_TIME}"
echo "----------------------------------------------------------------------------------------------------------------_"
echo 

echo "----------------------------------------------------------------------------------------------------------------_"
bash -x -c "./per_on_single_dut.sh MAX32690 EvKit_V1 False ${JOB_CURR_TIME}"
echo "----------------------------------------------------------------------------------------------------------------_"
echo 

echo "----------------------------------------------------------------------------------------------------------------_"
bash -x -c "./per_on_single_dut.sh MAX32690 WLP_V1 False ${JOB_CURR_TIME}"
echo "----------------------------------------------------------------------------------------------------------------_"
echo 

echo "----------------------------------------------------------------------------------------------------------------_"
echo "add all results to per.zip"
echo "----------------------------------------------------------------------------------------------------------------_"
echo 

MSDK=~/Workspace/Resource_Share/Results
result_files=/tmp/msdk/ci/per/${JOB_CURR_TIME}_zip_list.txt
if [ -f $result_files ]; then
    while IFS= read -r line; do
        #echo $line
        if [[ `wc -c ${line} | awk '{print $1}'` -gt 0 ]]; then
            zip ${MSDK}/per.zip ${line}
        fi
    done <$result_files
fi

# show ULRs
url_file=/tmp/msdk/ci/per/${JOB_CURR_TIME}.url
echo "URLs are saved in file: $url_file"
echo ""

if [ -f $url_file ]; then
    cat $url_file
fi

# Because this is the local test, must move the per.zip to another place.
if [ -f ${MSDK}/per.zip ]; then
    bash -x -c "mv ${MSDK}/per.zip ~/Workspace/Resource_Share/Results/${JOB_CURR_TIME}_${CHIP_UC}-${BRD_TYPE}.zip"
fi
