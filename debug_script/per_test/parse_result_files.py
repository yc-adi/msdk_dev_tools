#!/usr/bin/env python3

from datetime import datetime as dt
import matplotlib.pyplot as plt
import os
import sys

WITH_PRINT = True
TARGET_DIR = os.path.expanduser("~/Workspace/ci_results/per")
START_TIME = "2023-02-26 11:30:00"
END_TIME = "2024-01-01 00:00:00"

# index for chip and board type
ndx_max32655_evkit_v1 = 0
ndx_max32665_evkit_v1 = 1
ndx_max32690_evkit_v1 = 2
ndx_max32690_wlp_v1 = 3
TOTAL_BOARDS = 3  # no ME18 WLP

names = [
    "max32655_evkit_v1",
    "max32665_evkit_v1",
    "max32690_evkit_v1",
    "max32690_wlp_v1"
]

ITEM_CNT = 6  # data in each line

# index for a record
ndx_chip_board_type = 0
ndx_msdk = 1
ndx_rf_phy = 2
ndx_pkt_len = 3
ndx_tx_pwr = 4
ndx_rx_pwr = 5
ndx_phy = 6
ndx_tx_per = 7
ndx_rx_per = 8
ndx_file = 9
TOTAL_RECORD_ITEMS = 10

max32655_evkit_v1_data = list()
max32665_evkit_v1_data = list()
max32690_evkit_v1_data = list()
max32690_wlp_v1_data = list()

all_data = [
    max32655_evkit_v1_data,
    max32665_evkit_v1_data,
    max32690_evkit_v1_data,
    max32690_wlp_v1_data
]

record_file = os.path.expanduser('~/Workspace/ci_results/all_per_results_' + dt.now().strftime("%Y-%m-%d_%H-%M-%S")
                                 + '.csv')
print(f'Save to file: {record_file}')

phys = [
    "1M",
    "2M",
    "S8",
    "S2"
]
#
# The best solution is to save each test point into a database:
# test_time, chip_lc, board_type, msdk_sha, rf_phy_sha, pkg_len, tx_pwr, phy, rx_pwr, per
#
# The quick solution is to save each test point into a txt file
# ~/Workspace/ci_results/all_per_test_points.csv
#


def PRINT(msg, log=True):
    """customize print
    """
    if WITH_PRINT:
        print(f'{msg}')

    if log:
        pass
        # TODO: add log


def get_all_res_files(target_dir: str, start_time: str, end_time: str) -> list:
    files = list()
    start = dt.strptime(start_time, "%Y-%m-%d %H:%M:%S")
    end = dt.strptime(end_time, "%Y-%m-%d %H:%M:%S")

    # Iterate through all files in the folder
    for file_name in os.listdir(target_dir):
        file_path = os.path.join(target_dir, file_name)

        # Check if the file is a regular file
        if os.path.isfile(file_path):
            # Get the modification time of the file
            mod_time = dt.fromtimestamp(os.path.getmtime(file_path))
            # PRINT(mod_time)

            # Check if the file modification time is within the start and end time range
            if start <= mod_time <= end and file_name.find("_V1.csv") != -1:
                #PRINT(file_name)
                files.append(file_path)

    return files


def process_target_files(files: list):
    """process the targeted files in a list
    """
    for file in files:
        process_single_file(file)


def process_single_file(file: str):
    """process a single file
        local_full_per_test_2023-02027_00-30-08_max32690_EvKit_v1.csv
        Example:
            packetLen,phy,atten,txPower,perMaster,perSlave
            250,1,-20,0,0.0,0.0
            250,1,-70,0,0.0,0.0
            250,1,-90,0,5.04,3.13

            250,2,-20,0,0.0,0.0
    """
    global all_data

    if file.lower().find('max32655_evkit') != -1:
        chip_brd_type = names[ndx_max32655_evkit_v1]
        ndx = ndx_max32655_evkit_v1
    elif file.lower().find('max32665_evkit') != -1:
        chip_brd_type = names[ndx_max32665_evkit_v1]
        ndx = ndx_max32665_evkit_v1
    elif file.lower().find('max32690_evkit') != -1:
        chip_brd_type = names[ndx_max32690_evkit_v1]
        ndx = ndx_max32690_evkit_v1
    else:
        chip_brd_type = names[ndx_max32690_wlp_v1]
        ndx = ndx_max32690_wlp_v1

    file_saved = open(record_file, 'a')
    data_file = open(file, 'r')
    while True:
        line = data_file.readline()

        if not line:
            break

        temp = line.replace('\n', '').strip().split(',')
        if len(temp) != ITEM_CNT:
            continue

        if not temp[0].replace('.', '', 1).isdigit(): # ignore lines of comment
            continue

        record = [None] * TOTAL_RECORD_ITEMS
        record[ndx_chip_board_type] = chip_brd_type
        record[ndx_msdk] = ""
        record[ndx_rf_phy] = ""
        record[ndx_pkt_len] = int(temp[0])
        record[ndx_tx_pwr] = float(temp[3])
        record[ndx_rx_pwr] = float(temp[2])
        record[ndx_phy] = int(temp[1])
        record[ndx_tx_per] = float(temp[4])
        record[ndx_rx_per] = float(temp[5])
        record[ndx_file] = file

        # TODO: check if it is already in the record file
        all_data[ndx].append(record)
        data = ""
        for i in range(TOTAL_RECORD_ITEMS):
            data += f'{record[i]},'
        file_saved.write(data + '\n')

    data_file.close()
    file_saved.close()


def plot_all_points():
    """plot each PER
        subplots are arranged in the order by: pkt_len, phy, tx_pwr
    """
    PRINT("# Plot all the points.")
    COLS = 4  # phy: 0, 1, 2, 3
    ROWS = 2  # pkt_len * tx_pwr = 2 * 1

    fig = [None] * TOTAL_BOARDS
    axs = [None] * TOTAL_BOARDS

    # basic info of each figure
    for b in range(TOTAL_BOARDS):
        fig[b], axs[b] = plt.subplots(ROWS, COLS)
        fig[b].suptitle(f'Packet Error Rate (PER) vs Rx Power\n{names[b]}', fontsize=10)
        fig[b].tight_layout()
        plt.subplots_adjust(top=0.80, bottom=0.1, hspace=0.5)

        for row in range(ROWS):
            for col in range(COLS):
                plt.sca(axs[b][row, col])
                title = f'pkt_len:{250 if row == 0 else 0}, phy:{phys[col]}'
                axs[b][row, col].set_title(title, fontdict={'fontsize': 6, 'fontweight': 'medium'})
                axs[b][row, col].set_xlabel('Rx Power (dBm)', fontdict={"fontsize": 4})
                axs[b][row, col].set_ylabel('PER (%)', fontdict={"fontsize": 4})
                axs[b][row, col].tick_params(axis='both', which='major', labelsize=4)
                axs[b][row, col].axhline(y=30, color='r', linestyle=':', linewidth=0.5)

        fig[b].text(.5, .01, f'Run on all data channels (no advertising channels).\nother notes here', ha='center',
                    fontdict={"fontsize": 5})

    # plot each point at corresponding figure
    for brd_points in all_data:
        for point in brd_points:
            if point[ndx_chip_board_type] == "max32655_evkit_v1":
                b = 0
            elif point[ndx_chip_board_type] == "max32665_evkit_v1":
                b = 1
            elif point[ndx_chip_board_type] == "max32690_evkit_v1":
                b = 2
            else:
                # TODO: b = 3
                continue

            row = 0 if point[ndx_pkt_len] == 250 else 1
            col = point[ndx_phy] - 1
            plt.sca(axs[b][row, col])
            axs[b][row, col].plot(point[ndx_rx_pwr], point[ndx_rx_per], marker='.', color='blue', markersize=1)

    # save each figure
    for b in range(TOTAL_BOARDS):
        pdf_file = record_file.replace('.csv', '')
        pdf_file = f'{pdf_file}_{names[b]}.pdf'
        fig[b].savefig(pdf_file)


if __name__ == "__main__":
    PRINT("#----------------------------------------------------------------------------------------------------------")
    PRINT("# Check the result folder and find all needed files.")
    res_files = get_all_res_files(TARGET_DIR, START_TIME, END_TIME)

    # PRINT(res_files)
    process_target_files(res_files)

    plot_all_points()

    print("DONE!")

