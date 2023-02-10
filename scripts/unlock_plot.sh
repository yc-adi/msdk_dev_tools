#!/usr/bin/env bash

echo "#############################################################################################"
echo "# ./unlock_plot.sh GITHUB_WORKSPACE LOCK_FILE_LIST PER_RESULT_FILE NEED_TO_PLOT             #"
echo "#############################################################################################"
echo
echo $0 $@
echo

if [ "x$2" == "x" ] || [ "x$3" == "x" ]; then
    echo "ERR: Invalid arguments."
    exit 2
fi

GITHUB_WORKSPACE=$1
CURR_JOB_FILE=$2
all_in_one=$3
NEED_TO_PLOT=$4

echo CURR_JOB_FILE: ${CURR_JOB_FILE}
echo "Result file: "${all_in_one}
echo

# Use python 3.10.9
source ~/anaconda3/etc/profile.d/conda.sh && conda activate py3_10
python3 -c "import sys; print(sys.version)"
echo

echo "-----------------------------------------------------------------------------------"
echo "Unlock the used resource files."
echo

echo "Show lock files in folder Resource_Share."
ls -hal /home/$USER/Workspace/Resource_Share/*.txt
echo

if [ -f "${CURR_JOB_FILE}" ]; then
    echo "Show locked files for this job."
    cat ${CURR_JOB_FILE}
    echo

    while IFS= read -r line; do
        echo "python3 /home/$USER/Workspace/Resource_Share/Resource_Share.py ${line}"
        python3 /home/$USER/Workspace/Resource_Share/Resource_Share.py ${line}
    done <$CURR_JOB_FILE
else
    echo "${CURR_JOB_FILE} not exist."
fi
echo

echo "Show lock files in folder Resource_Share."
ls -hal /home/$USER/Workspace/Resource_Share/*.txt
echo

if [ "${NEED_TO_PLOT}" != "True" ]; then
    echo "No need to plot the PER results."
    exit 0
fi

echo "-----------------------------------------------------------------------------------"
echo "Plot the results"
echo

cd $GITHUB_WORKSPACE
echo PWD: `pwd`
echo

cd msdk_ci_per_tool
chmod u+x plot_per_results.py
echo ".plot_per_results.py ${all_in_one} desc basename"
./plot_per_results.py ${all_in_one} desc basename

echo "$0: DONE!"
