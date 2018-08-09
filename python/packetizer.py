import sys
import packet_func
import json
import pandas as pd
import datetime


def import_timing_config(timing_fname):
    try:
        with open(timing_fname, 'r') as f:
            j = json.load(f)
    except OSError:
        print('Unable to Open RC+S Timing Dictionary\nDefaulting to Standard Config', file=sys.stderr)
        return {0: 40, 1: 20, 2: 40}
    return {int(x): y for x, y in j.items()}


def import_td_json(td_fname):
    try:
        with open(td_fname, 'r') as f:
            j = json.load(f)
    except OSError:
        print('Unable to Open RC+S Time Domain File', file=sys.stderr)
        sys.exit(2)
    return j[0]


def send_to_csv(timestamps, voltage):
    df = pd.DataFrame(voltage)
    df['time_seconds'] = timestamps
    df.to_csv('./rc_s_time_domain_data.csv', index=False)
    return


def make_log_file(logfile_fd, input_td_data, lost_packet_array):
    session_start_time = input_td_data['RecordInfo']['HostUnixTime'] / 1000
    dt = datetime.datetime.fromtimestamp(session_start_time)
    logfile_fd.write('Log for RC+S Time Domain Recording Created On: {}\n'.format(dt.strftime('%Y-%m-%d %H-%M-%S')))
    lost_packet_num = 0
    for i in lost_packet_array.values():
        lost_packet_num += i[0]
    logfile_fd.write('Total Packets Lost: {}\n'.format(lost_packet_num))
    for i, j in lost_packet_array.items():
        logfile_fd.write(
            'Between Packet {0} and Packet {1}, {2} Packets Were Lost for a Total Loss of {3} Data Points\n'.format(
                i - 1,
                i, j[0], j[1]))
    return


def main():
    if len(sys.argv) != 3:
        print('Usage: python packetizer.py timing_config.json time_domain.json')
        sys.exit(1)
    timing_settings = import_timing_config(sys.argv[1])
    time_domain_data = import_td_json(sys.argv[2])
    log_file = open('./logfile.txt', 'a')
    timestamp_array, voltage_array, lost_packets = packet_func.packet_time_calculator_silent(time_domain_data,
                                                                                             timing_settings)
    send_to_csv(timestamp_array, voltage_array)
    make_log_file(log_file, time_domain_data, lost_packets)
    log_file.close()
    sys.exit(0)


if __name__ == '__main__':
    main()
