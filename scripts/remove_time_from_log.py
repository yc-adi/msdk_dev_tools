#!/usr/bin/env python3

import argparse
import os
import readline
import sys

parser = argparse.ArgumentParser()
parser.add_argument("--file", help="the log file")

args = parser.parse_args()

if args.file is None:
    print("input the log file path")
    sys.exit(1)

if not os.path.isfile(args.file):
    print("log file does not exist.")
    sys.exit(2)

with open(os.path.expanduser(args.file), 'r') as file, open(os.path.expanduser(args.file+".new"), 'w') as new_file:
    while True:
        line = file.readline()

        if not line:
            break

        #print(line.strip())
        if line.find("2023-") != -1:
            temp = line.split(" ")
            line = line.replace(temp[0] + " " + temp[1] + " ", "")

        new_file.writelines(line)


print("Done!")
