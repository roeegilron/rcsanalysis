import numpy as np
import datetime as dt
import pandas as pd

# Note: This function is deprecated!!!!!! Please see the 'silent' version below.
def packet_time_calculator_verbose(input_packets):
    current_run_time = 0
    backtrack_time = 0
    old_run_time = 0
    old_packet_time = input_packets[0]['Header']['systemTick']

    current_packet_number = input_packets[0]['Header']['dataTypeSequence']
    old_packet_number = input_packets[0]['Header']['dataTypeSequence']
    packet_counter = 0
    lost_packet_array = []

    voltage_array = {x['Key']: np.empty(0) for x in input_packets[0]['ChannelSamples']}
    timestamp_array = np.empty(0)

    for i in input_packets:
        num_points = i['Header']['dataSize'] // 4
        print('Num Data Points: {}'.format(num_points))
        current_run_time += ((i['Header']['systemTick'] - old_packet_time) % (2 ** 16))
        print('Current Run Time: {}'.format(current_run_time))
        backtrack_time = current_run_time - (
                (num_points - 1) * 10)  # 100usec * 10 = 1msec (period for recording at 1000Hz)
        print('Backtrack Time {}'.format(backtrack_time))
        print('Upcoming Packet Number: {}'.format(i['Header']['dataTypeSequence']))
        current_packet_number = (i['Header']['dataTypeSequence'] - old_packet_number) % (2 ** 8)
        print('Packet Delta: {}'.format(current_packet_number))
        print('Old Packet Number: {}\n'.format(old_packet_number))
        if (current_packet_number > 1):
            print("^We just lost a packet...^\n")
            lost_packet_array.append(packet_counter)
            print('Old Packet Time: {}'.format(old_run_time))
            lower_bound_time = old_run_time + 10
            print('Missing Packet Lower Bound Time: {}'.format(lower_bound_time))
            missing_data_count = ((backtrack_time - lower_bound_time) // 10)
            print('Missing Data Count: {}'.format(missing_data_count))
            timestamp_array = np.append(timestamp_array,
                                        np.linspace(lower_bound_time, (backtrack_time), missing_data_count,
                                                    endpoint=False))
            for j in i['ChannelSamples']:
                voltage_array[j['Key']] = np.append(voltage_array[j['Key']], np.array([0] * missing_data_count))

        timestamp_array = np.append(timestamp_array, np.linspace(backtrack_time, current_run_time, num_points))
        for j in i['ChannelSamples']:
            voltage_array[j['Key']] = np.append(voltage_array[j['Key']], j['Value'])

        old_run_time = current_run_time
        old_packet_number = i['Header']['dataTypeSequence']
        old_packet_time = i['Header']['systemTick']
        packet_counter += 1

    return ((timestamp_array - timestamp_array[0]), voltage_array, lost_packet_array)


def packet_time_calculator_silent(input_td_data, timing_dict, td_packet_str='TimeDomainData'):
    td_packets = input_td_data[td_packet_str]
    num_points_divisor = 2 * len(td_packets[0]['ChannelSamples'])

    current_run_time = 0
    old_run_time = 0
    old_packet_time = td_packets[0]['Header']['systemTick']

    old_packet_number = td_packets[0]['Header']['dataTypeSequence']
    packet_counter = 0
    lost_packet_array = {}

    voltage_array = {x['Key']: np.empty(0) for x in td_packets[0]['ChannelSamples']}
    timestamp_array = np.empty(0)

    timing_multiplier = timing_dict[td_packets[0]['SampleRate']]  # Assume uniform timing in TD data

    for i in td_packets:
        num_points = i['Header']['dataSize'] // num_points_divisor
        #             print('Num Data Points: {}'.format(num_points))
        current_run_time += ((i['Header']['systemTick'] - old_packet_time) % (2 ** 16))
        #             print('Current Run Time: {}'.format(current_run_time))
        backtrack_time = current_run_time - ((num_points - 1) * timing_multiplier)
        #             print('Backtrack Time {}'.format(backtrack_time))
        #             print('Upcoming Packet Number: {}'.format(i['Header']['dataTypeSequence']))
        packet_delta = (i['Header']['dataTypeSequence'] - old_packet_number) % (2 ** 8)
        #             print('Packet Delta: {}'.format(current_packet_number))
        #             print('Old Packet Number: {}\n'.format(old_packet_number))
        if packet_delta > 1:
            #                 print("^We just lost a packet...^\n")
            #                 print('Old Packet Time: {}'.format(old_run_time))
            lower_bound_time = old_run_time + timing_multiplier
            #                 print('Missing Packet Lower Bound Time: {}'.format(lower_bound_time))
            missing_data_count = ((backtrack_time - lower_bound_time) // timing_multiplier)
            lost_packet_array[packet_counter] = [packet_delta, missing_data_count]
            #                 print('Missing Data Count: {}'.format(missing_data_count))
            timestamp_array = np.append(timestamp_array,
                                        np.linspace(lower_bound_time, backtrack_time, missing_data_count,
                                                    endpoint=False))
            for j in i['ChannelSamples']:
                voltage_array[j['Key']] = np.append(voltage_array[j['Key']], np.array([0] * missing_data_count))

        timestamp_array = np.append(timestamp_array, np.linspace(backtrack_time, current_run_time, num_points))
        for j in i['ChannelSamples']:
            voltage_array[j['Key']] = np.append(voltage_array[j['Key']], j['Value'])

        old_run_time = current_run_time
        old_packet_number = i['Header']['dataTypeSequence']
        old_packet_time = i['Header']['systemTick']
        packet_counter += 1

    return [((timestamp_array - timestamp_array[0]) * 0.0001), voltage_array, lost_packet_array]


""" All the Code Below Is For the Second Generation Packetizer """


def init_numpy_array(input_json, num_cols):
    num_rows = len(input_json[0]['TimeDomainData'])
    return np.zeros((num_rows, num_cols))


def extract_td_meta_data(input_json):
    meta_matrix = init_numpy_array(input_json, 11)
    for index, packet in enumerate(input_json[0]['TimeDomainData']):
        meta_matrix[index, 0] = packet['Header']['dataSize']
        meta_matrix[index, 1] = packet['Header']['dataTypeSequence']
        meta_matrix[index, 2] = packet['Header']['systemTick']
        meta_matrix[index, 3] = packet['Header']['timestamp']['seconds']
        meta_matrix[index, 7] = index
        meta_matrix[index, 8] = len(packet['ChannelSamples'])
        meta_matrix[index, 9] = packet['Header']['dataSize'] / (2 * len(packet['ChannelSamples']))
        meta_matrix[index, 10] = packet['SampleRate']
    return meta_matrix


def code_micro_and_macro_packet_loss(meta_matrix):
    meta_matrix[np.where((np.diff(meta_matrix[:, 1]) % (2 ** 8)) > 1)[0] + 1, 4] = 1  # Top packet of microloss
    meta_matrix[np.where((np.diff(meta_matrix[:, 3]) >= ((2 ** 16) * .0001)))[0] + 1, 5] = 1  # Top packet of macroloss
    meta_matrix[:, 6] = ((meta_matrix[:, 4]).astype(int) & (meta_matrix[:, 5]).astype(
        int))  # Code coincidence of micro and macro loss
    return meta_matrix


def calculate_statistics(meta_array, intersample_tick_count):
    num_real_points = meta_array[:, 9].sum()
    num_macro_rollovers = meta_array[:, 5].sum()
    micro_loss_stack = np.dstack((np.where(meta_array[:, 4] == 1)[0] - 1, np.where(meta_array[:, 4] == 1)[0]))[0]

    # Remove micropacket losses that coincided with macropacket losses
    micro_loss_stack = micro_loss_stack[
        np.isin(micro_loss_stack[:, 1], np.where(meta_array[:, 5] == 1)[0], invert=True)]

    # Allocate array for calculating micropacket loss
    loss_array = np.zeros(len(micro_loss_stack))

    # Loop over meta data to extract and calculate micropacket loss.
    for index, packet in enumerate(micro_loss_stack):
        loss_array[index] = (((meta_array[packet[1], 2] - (meta_array[packet[1], 9] * intersample_tick_count)) -
                              meta_array[packet[0], 2]) % (2 ** 16)) / intersample_tick_count

    # Calculate the total number of lost data points due to micropacket loss.
    loss_as_scalar = np.around(loss_array).sum()

    return num_real_points, num_macro_rollovers, loss_as_scalar


def unpacker(meta_array, input_json, intersample_tick_count):
    # First we verify that the number of channels and sampling rate does not change
    if np.diff(meta_array[:, 8]).sum():
        raise ValueError('Number of Active Channels Changes Throughout the Recording')
    if np.diff(meta_array[:, 10]).sum():
        raise ValueError('Sampling Rate Changes Throughout the Recording')

    # Initialize array to hold output data
    final_array = np.zeros((meta_array[:, 9].sum().astype(int), 2 + meta_array[0, 8].astype(int)))

    # Initialize variables for looping:
    array_bottom = 0
    master_time = meta_array[0, 3]
    old_system_tick = 0
    running_us_counter = 0

    # Loop over metadata and
    for i in meta_array:
        if i[5]:
            # We just suffered a macro packet loss...
            old_system_tick = 0
            running_us_counter = 0
            master_time = i[3]  # Resets the master time

        running_us_counter += ((i[2] - old_system_tick) % (2 ** 16))
        backtrack_time = running_us_counter - ((i[9] - 1) * intersample_tick_count)

        # Populate master clock time into array
        final_array[int(array_bottom):int(array_bottom + i[9]), 0] = np.array([master_time] * int(i[9]))

        # Linspace microsecond clock and populate into array
        final_array[int(array_bottom):int(array_bottom + i[9]), 1] = np.linspace(backtrack_time, running_us_counter,
                                                                                 int(i[9]))

        # Unpack time domain data from original packets into array
        for j in range(0, int(i[8])):
            final_array[int(array_bottom):int(array_bottom + i[9]), j + 2] = \
                input_json[0]['TimeDomainData'][int(i[7])]['ChannelSamples'][j]['Value']

        # Update counters for next loop
        old_system_tick = i[2]
        array_bottom += i[9]

    # Convert systemTicks into microseconds
    final_array[:, 1] = final_array[:, 1] * 100

    return final_array


# time_df.time_master = pd.to_datetime(time_df.time_master, unit='s', origin=pd.Timestamp('2000-03-01'))

def save_to_disk(data_matrix, filename_str, time_format, data_type):
    num_cols = data_matrix.shape[1]
    if data_type == 'accel':
        channel_names = ['accel_' + x for x in ['x', 'y', 'z']]
    else:
        channel_names = ['channel_' + str(x) for x in range(0, num_cols)]
    column_names = ['time_master', 'microseconds'] + channel_names
    df = pd.DataFrame(data_matrix, columns=column_names)
    if time_format == 'full':
        df.time_master = pd.to_datetime(df.time_master, unit='s', origin=pd.Timestamp('2000-03-01'))
        df.microseconds = pd.to_timedelta(df.microseconds, unit='us')
        df['actual_time'] = df.time_master + df.microseconds
        df.to_csv(filename_str, index=False)
    else:
        df.to_csv(filename_str, index=False)
    return


def print_session_statistics():
    # TODO: Implement a printing function to show statistics to the user at the end of processing
    return
