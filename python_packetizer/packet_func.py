import numpy as np


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
        num_points = i['Header']['dataSize'] // 4
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
