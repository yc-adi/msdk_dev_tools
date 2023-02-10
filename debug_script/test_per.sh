#!/usr/bin/env bash

echo `python3 -c "import sys; print(sys.version)"`
echo "source ~/softwares/anaconda3/etc/profile.d/conda.sh && conda activate py3_10"
source ~/softwares/anaconda3/etc/profile.d/conda.sh && conda activate py3_10
echo `python3 -c "import sys; print(sys.version)"`