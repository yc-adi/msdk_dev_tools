#!/usr/bin/env python3


from datetime import datetime as dt
import os
from subprocess import call, Popen, PIPE, CalledProcessError, STDOUT


"""
/tmp/msdk/ci/per/2023-02-16_11-33-12_brd2_reset.sh
"""
def run_script_reset_board(sh_file):
    """call a prepared script file to reset a board"""
    sh_file = os.path.realpath(sh_file)
    print(f"Run script file {sh_file}.")
    p = Popen([f'{sh_file}'], stdout=PIPE, stderr=PIPE, shell=True)

    for line in iter(p.stdout.readline, b''):
        print(f'{dt.now()} - {line.strip().decode("utf-8")}')
    
    p.stdout.close()
    p.wait()
    result = p.returncode
    print(f'Exit: {result}')
    return result

file = "/tmp/msdk/ci/per/2023-02-16_11-33-12_brd2_reset.sh"

run_script_reset_board(file)

print("done!")