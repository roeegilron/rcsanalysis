%--------------------------------------------------------------------------
% Copyright (c) Medtronic, Inc. 2017
%
% MEDTRONIC CONFIDENTIAL -- This document is the property of Medtronic
% PLC, and must be accounted for. Information herein is confidential trade
% secret information. Do not reproduce it, reveal it to unauthorized 
% persons, or send it outside Medtronic without proper authorization.
%--------------------------------------------------------------------------
%
% File Name: Plot_JSON.m
% Author: Ben Johnson (johnsb68)
%
% Description: This file contains the MATLAB script for read in the JSON files and
% plotting the data. This script is sectioned to allow step by step evaluation using 
% the "Run and Advance" or "Run Section" MATLAB feature.
%
% -------------------------------------------------------------------------
%% Get All JSON Files****************************************************************
clear, clc
disp('choose JSON folder to plot data from')
pathname = uigetdir();
addpath(pathname);
AdaptiveLog=jsondecode(fixMalformedJson(fileread('AdaptiveLog.json'),'AdaptiveLog'));
DeviceSettings=jsondecode(fixMalformedJson(fileread('DeviceSettings.json'),'DeviceSettings'));
DiagnosticsLog=jsondecode(fixMalformedJson(fileread('DiagnosticsLog.json'),'DiagnosticsLog'));
ErrorLog=jsondecode(fixMalformedJson(fileread('ErrorLog.json'),'ErrorLog'));
EventLog=jsondecode(fixMalformedJson(fileread('EventLog.json'),'EventLog'));
RawDataAccel=jsondecode(fixMalformedJson(fileread('RawDataAccel.json'),'RawDataAccel'));
RawDataFFT=jsondecode(fixMalformedJson(fileread('RawDataFFT.json'),'RawDataFFT'));
RawDataPower=jsondecode(fixMalformedJson(fileread('RawDataPower.json'),'RawDataPower'));
RawDataTD=jsondecode(fixMalformedJson(fileread('RawDataTD.json'),'RawDataTD'));
StimLog=jsondecode(fixMalformedJson(fileread('StimLog.json'),'StimLog'));
TimeSync=jsondecode(fixMalformedJson(fileread('TimeSync.json'),'TimeSync'));
rmpath(pathname);
%% Find First Good Packet Gen Time***************************************************
FirstGoodTimeAll = NaN(5,1);
if ~isempty(RawDataTD.TimeDomainData)
for ii = 1:1:length(RawDataTD.TimeDomainData) % Find the first TD Gen Time
    if RawDataTD.TimeDomainData(ii).PacketGenTime > 0
        FirstGoodTimeAll(1,1) = RawDataTD.TimeDomainData(ii).PacketGenTime;
        break
    end
end
end
if ~isempty(RawDataFFT.FftData)
for ii = 1:1:length(RawDataFFT.FftData) % Find the first FFT Gen Time
    if RawDataFFT.FftData(ii).PacketGenTime > 0
        FirstGoodTimeAll(2,1) = RawDataFFT.FftData(ii).PacketGenTime;
        break
    end
end
end
if ~isempty(RawDataPower.PowerDomainData)
for ii = 1:1:length(RawDataPower.PowerDomainData) % Find the first Power Gen Time
    if RawDataPower.PowerDomainData(ii).PacketGenTime > 0
        FirstGoodTimeAll(3,1) = RawDataPower.PowerDomainData(ii).PacketGenTime;
        break
    end
end
end
if ~isempty(RawDataAccel.AccelData)
for ii = 1:1:length(RawDataAccel.AccelData) % Find the first Accel Gen Time
    if RawDataAccel.AccelData(ii).PacketGenTime > 0
        FirstGoodTimeAll(4,1) = RawDataAccel.AccelData(ii).PacketGenTime;
        break
    end
end
end
if ~isempty(AdaptiveLog)
for ii = 1:1:length(AdaptiveLog) % Find the first Adaptive Gen Time
    if AdaptiveLog(ii).AdaptiveUpdate.PacketGenTime > 0
        FirstGoodTimeAll(5,1) = AdaptiveLog(ii).AdaptiveUpdate.PacketGenTime;
        break
    end
end
end
FirstGoodTime = min(FirstGoodTimeAll); %Used when using Packet Gen Time for plotting
% This will be used as a reference for all plots when plotting based off Packet Gen
% Time. It is the end of the first streamed packet. The first received sample is
% considered the zero reference.
%% Find Master System Tick and Master Time Stamp*************************************
masterTickArray = NaN(6,1);
masterTimeStampArray = NaN(6,1);
if ~isempty(RawDataTD.TimeDomainData) % Find the first TD Sys Tick and Timestamp
    masterTickArray(1) = RawDataTD.TimeDomainData(1).Header.systemTick;
    masterTimeStampArray(1) = RawDataTD.TimeDomainData(1).Header.timestamp.seconds;
end
if ~isempty(RawDataAccel.AccelData) % Find the first Accel Sys Tick and Timestamp
    masterTickArray(2) = RawDataAccel.AccelData(1).Header.systemTick;
    masterTimeStampArray(2) = RawDataAccel.AccelData(1).Header.timestamp.seconds;
end
if ~isempty(TimeSync.TimeSyncData) % Find the first Time Sync Sys Tick and Timestamp
    masterTickArray(3) = TimeSync.TimeSyncData(1).Header.systemTick;
    masterTimeStampArray(3) = TimeSync.TimeSyncData(1).Header.timestamp.seconds;
end
if ~isempty(RawDataFFT.FftData) % Find the first FFT Sys Tick and Timestamp
    masterTickArray(4) = RawDataFFT.FftData(1).Header.systemTick;
    masterTimeStampArray(4) = RawDataFFT.FftData(1).Header.timestamp.seconds;
end
if ~isempty(RawDataPower.PowerDomainData) % Find the first Pow Sys Tick and Timestamp
    masterTickArray(5) = RawDataPower.PowerDomainData(1).Header.systemTick;
    masterTimeStampArray(5) = RawDataPower.PowerDomainData(1).Header.timestamp.seconds;
end
if ~isempty(AdaptiveLog) % Find the first Adaptive Sys Tick and Timestamp
    masterTickArray(6) = AdaptiveLog(1).AdaptiveUpdate.Header.systemTick;
    masterTimeStampArray(6) = AdaptiveLog(1).AdaptiveUpdate.Header.timestamp.seconds;
end
masterTimeStamp = min(masterTimeStampArray);
I = find(masterTimeStampArray == masterTimeStamp);
masterTick = min(masterTickArray(I));
% This (masterTimeStamp and masterTick) will be used as a reference for all plots
% when plotting based off System Tick. It is the end of the first streamed packet.
% The first received sample is considered the zero reference.
rolloverseconds = 6.5535; % System Tick seconds before roll over
%% Find Relative First Packet End Time***********************************************
for i = length(DeviceSettings):-1:1 % Get last configured sample rate
    if isfield(DeviceSettings{i,1}, 'SensingConfig') 
        if isfield(DeviceSettings{i,1}.SensingConfig, 'timeDomainChannels')
            if DeviceSettings{i,1}.SensingConfig.timeDomainChannels(1).sampleRate==0
                SampleRate=250; %Hz
            elseif DeviceSettings{i,1}.SensingConfig.timeDomainChannels(1).sampleRate==1
                SampleRate=500;
            elseif DeviceSettings{i,1}.SensingConfig.timeDomainChannels(1).sampleRate==2
                SampleRate=1000;
            else
                if DeviceSettings{i,1}.SensingConfig.timeDomainChannels(2).sampleRate==0
                    SampleRate=250; %Hz
                elseif DeviceSettings{i,1}.SensingConfig.timeDomainChannels(2).sampleRate==1
                    SampleRate=500;
                elseif DeviceSettings{i,1}.SensingConfig.timeDomainChannels(2).sampleRate==2
                    SampleRate=1000;
                else
                    if DeviceSettings{i,1}.SensingConfig.timeDomainChannels(3).sampleRate==0
                        SampleRate=250; %Hz
                    elseif DeviceSettings{i,1}.SensingConfig.timeDomainChannels(3).sampleRate==1
                        SampleRate=500;
                    elseif DeviceSettings{i,1}.SensingConfig.timeDomainChannels(3).sampleRate==2
                        SampleRate=1000;
                    else
                        if DeviceSettings{i,1}.SensingConfig.timeDomainChannels(4).sampleRate==0
                            SampleRate=250; %Hz
                        elseif DeviceSettings{i,1}.SensingConfig.timeDomainChannels(4).sampleRate==1
                            SampleRate=500;
                        elseif DeviceSettings{i,1}.SensingConfig.timeDomainChannels(4).sampleRate==2
                            SampleRate=1000;
                        else
                            disp('Error: undefined sampling rate')
                        end
                    end
                end
            end
            break
        end
    end
end
if I == 1 % if a time domain packet was the first packet received
    endtime1 = (size(RawDataTD.TimeDomainData(1).ChannelSamples(1).Value,1)-1)/SampleRate;
    % Sets the first packet end time in seconds based off samples and sample rate.
    % This is used as a reference for FFT, Power, and Adaptive data because these are
    % calculated after the TD data has been acquired. Accel data generates its own
    % first packet end time in seconds.
else
    endtime1 = 0;
end
%% Get General User Preferences (Timing and Spacing Schemes)*************************
if isnan(FirstGoodTime)
    disp('Time Sync not enabled. Do not plot based off Packet Gen Time!')
end
prompt = 'Input 1 to plot based off system tick or input 2 to plot based off Packet Gen Time: ';
timing = input(prompt, 's');
if strcmp(timing,'1')
    timing = true;
elseif strcmp(timing,'2')
    timing = false;
else
    error('Invalid Input')
end
prompt = 'Input 1 to linearly space packet data points or input 2 to space packet data points based off sample rate: ';
spacing = input(prompt, 's');
if strcmp(spacing,'1')
    spacing = true;
elseif strcmp(spacing,'2')
    spacing = false;
else
    error('Invalid Input')
end
%% Get TD User Preferences***********************************************************
prompt = 'Want to plot TD data? (y/n): ';
pref = input(prompt, 's');
if strcmp(pref,'y')
    prefTD = true;
elseif strcmp(pref,'n')
    prefTD = false;
else
    error('Invalid Input')
end
if prefTD == true
    prompt = 'Want to overlay Loop Record Data? (y/n): ';
    pref = input(prompt, 's');
    if strcmp(pref,'y')
        prefLR = true;
    elseif strcmp(pref,'n')
        prefLR = false;
    else
        error('Invalid Input')
    end
    prompt = 'Want to add markers where data points are? (y/n): ';
    pref = input(prompt, 's');
    if strcmp(pref,'y')
        prefsep = true;
    elseif strcmp(pref,'n')
        prefsep = false;
    else
        error('Invalid Input')
    end
    prompt = 'Want to overlay Evoked Response Markers? (y/n): ';
    pref = input(prompt, 's');
    if strcmp(pref,'y')
        prefEM = true;
    elseif strcmp(pref,'n')
        prefEM = false;
    else
        error('Invalid Input')
    end
end
%% Plot Time Domain Data*************************************************************
if ~isempty(RawDataTD.TimeDomainData) && prefTD == true %If there is data in the JSON File and user wants to plot the data
    NumberofChannels=size(RawDataTD.TimeDomainData(1).ChannelSamples,1);
    NumberofEvokedMarkers=size(RawDataTD.TimeDomainData(1).EvokedMarker,1);
    ChannelDataTD=cell(NumberofChannels,1); %Initializes Raw TD data structure
    PacketSize = 0; %Initialize Packet Sample Size structure
    EvokedMarker = cell(NumberofEvokedMarkers,1); %Initialize Evoked Marker data structure
    EvokedIndex = cell(NumberofEvokedMarkers,1); %Initialize Evoked Index data structure
    tvec = []; %Initializes time vector
    missedpacketgapsTD = 0; %Initializes missed packet count
    %Necessary if running this section consectutively--------------------------------
    if exist('stp','var')
        clear stp
    end
    %--------------------------------------------------------------------------------
    seconds = 0; %Initializes seconds addition due to looping
    % Determine corrective time offset-----------------------------------------------
    tickref = RawDataTD.TimeDomainData(1).Header.systemTick - masterTick;
    timestampref = RawDataTD.TimeDomainData(1).Header.timestamp.seconds - masterTimeStamp;
    if timestampref > 6
        seconds = seconds + timestampref; % if time stamp differs by 7 or more seconds make correction
    elseif tickref < 0 && timestampref > 0
        seconds = seconds + rolloverseconds; % adds initial loop time if needed
    end
    %--------------------------------------------------------------------------------
    loopcount = 0; %Initializes loop count
    looptimestamp = []; %Initializes loop time stamp index

    for ii = 1:1:length(RawDataTD.TimeDomainData) % loop through all data packets
       %Keep track of missed packets-------------------------------------------------
       if ii ~= 1
           if RawDataTD.TimeDomainData(ii-1).Header.dataTypeSequence == 255
               if RawDataTD.TimeDomainData(ii).Header.dataTypeSequence ~= 0 
                   missedpacketgapsTD = missedpacketgapsTD + 1;
               end
           else
               if RawDataTD.TimeDomainData(ii).Header.dataTypeSequence ~= RawDataTD.TimeDomainData(ii-1).Header.dataTypeSequence + 1
                   missedpacketgapsTD = missedpacketgapsTD + 1;
               end
           end
       end
       %-----------------------------------------------------------------------------
       if timing == true
       %plotting based off system tick***********************************************
           if ii == 1
               endtime = (RawDataTD.TimeDomainData(ii).Header.systemTick - masterTick)*0.0001 + endtime1 + seconds; % adjust the endtime of the first packet according to the masterTick
               endtimeold = endtime - (size(RawDataTD.TimeDomainData(1).ChannelSamples(1).Value,1)-1)/SampleRate; % plot back from endtime based off of sample rate
           else
               endtimeold = endtime;
               if RawDataTD.TimeDomainData(ii-1).Header.systemTick < RawDataTD.TimeDomainData(ii).Header.systemTick
                   endtime = (RawDataTD.TimeDomainData(ii).Header.systemTick - masterTick)*0.0001 + endtime1 + seconds;
               else
                   seconds = seconds + rolloverseconds;
                   endtime = (RawDataTD.TimeDomainData(ii).Header.systemTick - masterTick)*0.0001 + endtime1 + seconds;
               end
           end
           if spacing == true
           %linearly spacing data between packet system ticks------------------------
               if ii ~= 1
                   tvec = [tvec(1:end-1), linspace(endtimeold,endtime,size(RawDataTD.TimeDomainData(ii).ChannelSamples(1).Value,1)+1)]; % Linearly spacing between packet end times
               else
                   tvec = [tvec(1:end-1), linspace(endtimeold,endtime,size(RawDataTD.TimeDomainData(ii).ChannelSamples(1).Value,1))];
               end
           elseif spacing == false
           %sample rate spacing data between packet system ticks---------------------
               tvec = [tvec, endtime-(size(RawDataTD.TimeDomainData(ii).ChannelSamples(1).Value,1)-1)/SampleRate:1/SampleRate:endtime];
           end
           %-------------------------------------------------------------------------
           for i=1:NumberofChannels %Construct Raw TD Data Structure
               ChannelDataTD{i,1}= [ChannelDataTD{i,1}, RawDataTD.TimeDomainData(ii).ChannelSamples(i).Value'];
               PacketSize(ii) = size(RawDataTD.TimeDomainData(ii).ChannelSamples(1).Value,1); 
           end
       elseif timing == false
       %plotting based off packet gen times******************************************
           if RawDataTD.TimeDomainData(ii).PacketGenTime > 0 % Check for Packet Gen Time
               if spacing == true
               %linearly spacing data between packet gen times-----------------------
                   if ~exist('stp','var')
                       stp = 1;
                       endtime = (RawDataTD.TimeDomainData(ii).PacketGenTime-FirstGoodTime)/1000 + endtime1; % adjust the endtime of the first packet according to the FirstGoodTime
                       endtimeold = endtime - (size(RawDataTD.TimeDomainData(1).ChannelSamples(1).Value,1)-1)/SampleRate; % plot back from endtime based off of sample rate
                       tvec = [tvec(1:end-1), linspace(endtimeold,endtime,size(RawDataTD.TimeDomainData(ii).ChannelSamples(1).Value,1))];
                   else
                        endtimeold = endtime;
                        endtime = (RawDataTD.TimeDomainData(ii).PacketGenTime-FirstGoodTime)/1000 + endtime1;
                        tvec = [tvec(1:end-1), linspace(endtimeold,endtime,size(RawDataTD.TimeDomainData(ii).ChannelSamples(1).Value,1)+1)];
                   end
               elseif spacing == false
               %sample rate spacing data between packet gen times--------------------
                   endtime = (RawDataTD.TimeDomainData(ii).PacketGenTime-FirstGoodTime)/1000 + endtime1;
                   tvec = [tvec, endtime-(size(RawDataTD.TimeDomainData(ii).ChannelSamples(1).Value,1)-1)/SampleRate:1/SampleRate:endtime];
               end
               %---------------------------------------------------------------------
               for i=1:NumberofChannels %Construct Raw TD Data Structure
                   ChannelDataTD{i,1}= [ChannelDataTD{i,1}, RawDataTD.TimeDomainData(ii).ChannelSamples(i).Value'];
                   PacketSize(ii) = size(RawDataTD.TimeDomainData(ii).ChannelSamples(1).Value,1);
               end
           end
       end
       %*****************************************************************************
       if ii ~= 1
           if RawDataTD.TimeDomainData(ii-1).Header.systemTick > RawDataTD.TimeDomainData(ii).Header.systemTick
               loopcount = loopcount + 1;
               looptimestamp(end+1) = RawDataTD.TimeDomainData(ii).Header.timestamp.seconds;
           end
       end
    end
    
    if prefsep == true
        linestyle = 'b*-';
        linestyle2 = 'r-o';
    else
        linestyle = 'b-';
        linestyle2 = 'r-';
    end
    
    figure,
    for i=1:NumberofChannels
    TDaxi(i) = subplot(NumberofChannels,1,i);
    plot(tvec, ChannelDataTD{i,1},linestyle)
    title(['Time Domain Data Output: Channel ',int2str(RawDataTD.TimeDomainData(1).ChannelSamples(i).Key)])
    xlabel('Time (s)')
    ylabel('Voltage (mV)')
    end
    
    if prefEM == true %overlaying Evoked Markers if there are any
        if timing == true
        %plotting based off system tick**********************************************
            for ii = 1:1:length(RawDataTD.TimeDomainData) % loop through all data packets
                for i=1:NumberofEvokedMarkers %Construct Evoked Marker Data Structure
                    if ~isempty(RawDataTD.TimeDomainData(ii).EvokedMarker(i).Value)
                        EvokedMarker{i,1}= [EvokedMarker{i,1}, RawDataTD.TimeDomainData(ii).EvokedMarker(i).Value.TimeBeforeDataPointInMicroSeconds];
                        newindexes = [];
                        newindexes = [newindexes,RawDataTD.TimeDomainData(ii).EvokedMarker(i).Value.IndexOfDataPointFollowing];
                        newindexes = newindexes + 1 + sum(PacketSize(1:ii-1));
                        EvokedIndex{i,1}= [EvokedIndex{i,1}, tvec(newindexes)];
                    end
                end
            end
        elseif timing == false
        %plotting based off packet gen times*****************************************
            for ii = 1:1:length(RawDataTD.TimeDomainData) % loop through all data packets
                if RawDataTD.TimeDomainData(ii).PacketGenTime > 0 % Check for Packet Gen Time
                    for i=1:NumberofEvokedMarkers %Construct Evoked Marker Data Structure
                        if ~isempty(RawDataTD.TimeDomainData(ii).EvokedMarker(i).Value)
                            EvokedMarker{i,1}= [EvokedMarker{i,1}, RawDataTD.TimeDomainData(ii).EvokedMarker(i).Value.TimeBeforeDataPointInMicroSeconds];
                            newindexes = [];
                            newindexes = [newindexes,RawDataTD.TimeDomainData(ii).EvokedMarker(i).Value.IndexOfDataPointFollowing];
                            newindexes = newindexes + 1 + sum(PacketSize(1:ii-1));
                            EvokedIndex{i,1}= [EvokedIndex{i,1}, tvec(newindexes)];
                        end
                    end
                end
            end
        end
        for i=1:NumberofEvokedMarkers
            EvokedIndex{i,1} = EvokedIndex{i,1} - (EvokedMarker{i,1}./1000000);
            for j=1:length(EvokedIndex{i,1})
                line(TDaxi(i),[EvokedIndex{i,1}(j) EvokedIndex{i,1}(j)], get(TDaxi(i), 'ylim'),'LineWidth',1,'Color','r');
            end
        end
    end
    linkaxes(TDaxi,'x') % Link the x-axi

    secondsLRend = 0;
    endindex = cell(NumberofChannels,1);
    dataLR = cell(NumberofChannels,1);
    tvecLR = [];
    nolrdownload = true;
    if prefLR == true %overlaying LR data if it was downloaded
        % Find, construct, and plot LR downloads-------------------------------------
        for i = 1:length(DiagnosticsLog)
            if isfield(DiagnosticsLog{i,1},'LoopRecordDownload')
                nolrdownload = false;
                for jj = 1:NumberofChannels
                    if abs(DiagnosticsLog{i, 1}.LoopRecordDownload.ChannelSamples(jj).Value(end)) > 0
                        % if entire LR Buffer is full--------------------------------
                        dataLR{jj,1} = DiagnosticsLog{i, 1}.LoopRecordDownload.ChannelSamples(jj).Value';
                    else
                        % if not find last data point and construct data structure---
                        [endindex{jj,1},a,aa] = find(DiagnosticsLog{i, 1}.LoopRecordDownload.ChannelSamples(jj).Value==0);
                        for jjj = 1:length(endindex{jj,1})
                            if endindex{jj,1}(jjj) == endindex{jj,1}(jjj+1) - 1 && endindex{jj,1}(jjj+1) == endindex{jj,1}(jjj+2) - 1
                                dataLR{jj,1} = DiagnosticsLog{i, 1}.LoopRecordDownload.ChannelSamples(jj).Value(1:endindex{jj,1}(jjj)-1)';
                                break
                            end
                        end
                    end
                end
                % Determine last timestamp
                endtimestamp = DiagnosticsLog{i, 1}.LoopRecordDownload.LrStatus.endTimestamp.seconds;
                % Based off of last time stamp determine seconds offset----------
                for j = length(looptimestamp):-1:1
                    if endtimestamp > looptimestamp(j)
                        secondsLRend = j*rolloverseconds;
                        break
                    end
                end
                %----------------------------------------------------------------
                endtimeLR = (DiagnosticsLog{i, 1}.LoopRecordDownload.LrStatus.endSystemTick - RawDataTD.TimeDomainData(1).Header.systemTick)*0.0001 + endtime1 + secondsLRend;
                % Construct LR time vector based off LR endtime, sample rate, and
                % number of samples.
                tvecLR = linspace(endtimeLR-(length(dataLR{1,1}-1)/SampleRate),endtimeLR,length(dataLR{1,1}));
                % Find TD data indices that match 5 LR data points (Last 5 data pts. 
                % 10-15th to last data pts due to gap in TD data after LR end)
                col = cell(5,1);
                for j = 1:5
                [row,col{j},v] = find(ChannelDataTD{1,1}==dataLR{1,1}(1,end-14-j));
                end
                index = intersect(col{1},col{1});
                for j = 2:5
                    index = intersect(index,col{j}+j-1);
                end
                % Plot LR data on same timescale as TD data----------------------
                for ii=1:NumberofChannels
                    hold(TDaxi(ii), 'on')
                    if index-length(dataLR{1,1})+16 > 0
                        plot(TDaxi(ii),tvec(index-length(dataLR{1,1})+16:index),dataLR{ii,1}(1:end-15),linestyle2)
                    else
                        plot(TDaxi(ii),tvec(15:index),dataLR{ii,1}(length(dataLR{ii,1})-index:end-15),linestyle2)
                    end
                    legend(TDaxi(ii),'Streamed Data','LR Data')
                    hold(TDaxi(ii), 'off')
                end
                %----------------------------------------------------------------
            end
        end
        %----------------------------------------------------------------------------
        if nolrdownload == true % if LR data wasn't downloaded
            disp('No Loop Record Data Available to Plot')
        end
    end
elseif isempty(RawDataTD.TimeDomainData) %Inform user that there is no data in the JSON File
    disp('No TD Data Available to Plot')
end
%% Get FFT User Preferences**********************************************************
prompt = 'Want to plot FFT data? (y/n): ';
pref = input(prompt, 's');
if strcmp(pref,'y')
    prefFFT = true;
elseif strcmp(pref,'n')
    prefFFT = false;
else
    error('Invalid Input')
end

if prefFFT == true
    prompt = 'Input 1 to plot spectrogram or input 2 to plot singular FFT: ';
    pref = input(prompt, 's');
    if strcmp(pref,'1')
        preftype = true;
    elseif strcmp(pref,'2')
        preftype = false;
    else
        error('Invalid Input')
    end
    if preftype == false
        prompt = 'Input which FFT index to plot: ';
        prefindex = str2double(input(prompt, 's'));
    end
end
%% Plot FFT Data*********************************************************************
if ~isempty(RawDataFFT.FftData) && prefFFT == true %If there is data in the JSON File and user wants to plot the data
    fftsize=RawDataFFT.FftData(1).Header.dataSize;
    delta = SampleRate/fftsize;
    f=0:delta:(SampleRate/2)-delta;
    if preftype == false % singular FFT plot
        figure;
        plot(f,RawDataFFT.FftData(prefindex).FftOutput)
        title('FFT')
        xlabel('Frequency (Hz)')
        ylabel('Amplitude (mVp when using a 100% Hanning Window)') % undefined units for all other window types
    end

    if preftype == true % spectrogram plot
        % Initialize variables
        ChannelDataFFT=zeros(length(RawDataFFT.FftData),fftsize/2);
        tvec = zeros(1,length(RawDataFFT.FftData));
        missedpacketgapsFFT = 0;
        seconds = 0;
        % Determine corrective time offset-------------------------------------------
        tickref = RawDataFFT.FftData(1).Header.systemTick - masterTick;
        timestampref = RawDataFFT.FftData(1).Header.timestamp.seconds - masterTimeStamp;
        if timestampref > 6
            seconds = seconds + timestampref; % if time stamp differs by 7 or more seconds make correction
        elseif tickref < 0 && timestampref > 0
            seconds = seconds + rolloverseconds; % adds initial loop time if needed
        end
        %----------------------------------------------------------------------------
        for ii = 1:1:length(RawDataFFT.FftData)
            %Keep track of missed packets--------------------------------------------
            if ii ~= 1
                if RawDataFFT.FftData(ii-1).Header.dataTypeSequence == 255
                    if RawDataFFT.FftData(ii).Header.dataTypeSequence ~= 0
                        missedpacketgapsFFT = missedpacketgapsFFT + 1;
                    end
                else
                    if RawDataFFT.FftData(ii).Header.dataTypeSequence ~= RawDataFFT.FftData(ii-1).Header.dataTypeSequence + 1
                        missedpacketgapsFFT = missedpacketgapsFFT + 1;
                    end
                end
            end
            %------------------------------------------------------------------------
            if timing == true
            %plotting based off system tick******************************************
                if ii == 1 || RawDataFFT.FftData(ii-1).Header.systemTick < RawDataFFT.FftData(ii).Header.systemTick
                    endtime = (RawDataFFT.FftData(ii).Header.systemTick  - masterTick)*0.0001 + endtime1 + seconds;
                else
                    seconds = seconds + rolloverseconds;
                    endtime = (RawDataFFT.FftData(ii).Header.systemTick  - masterTick)*0.0001 + endtime1 + seconds;
                end
                tvec(ii) = endtime;
                ChannelDataFFT(ii,:)= RawDataFFT.FftData(ii).FftOutput;
            elseif timing == false
            %plotting based off packet gen times*************************************
                if RawDataFFT.FftData(ii).PacketGenTime > 0 % Check for Packet Gen Time
                    tvec(ii) = (RawDataFFT.FftData(ii).PacketGenTime-FirstGoodTime)/1000 + endtime1;
                    ChannelDataFFT(ii,:)= RawDataFFT.FftData(ii).FftOutput;
                end
            end
            %************************************************************************
        end
        figure;
        spect = imagesc(tvec(1:end),f,ChannelDataFFT(1:end,:)');
        c = colorbar('southoutside');
        c.Label.String = 'Magnitude (mVp when using a 100% Hanning Window)'; % % unitless for all other window types for all other window types
        title('Spectrogram')
        xlabel('Time (sec)')
        ylabel('Frequency (Hz)') 
    end
elseif isempty(RawDataFFT.FftData) %Inform user that there is no data in the JSON File
    disp('No FFT Data Available to Plot')
end
%% Get Power User Preferences********************************************************
prompt = 'Want to plot Power data? (y/n): ';
pref = input(prompt, 's');
if strcmp(pref,'y')
    prefPower = true;
elseif strcmp(pref,'n')
    prefPower = false;
else
    error('Invalid Input')
end
embeddedstateperformed = false; % Initialize embedded state change discovery as false
if prefPower == true
    prompt = 'Want to subplot stim amplitude, rate, and adaptive state? (y/n): ';
    pref = input(prompt, 's');
    if strcmp(pref,'y')
        prefad = true;
    elseif strcmp(pref,'n')
        prefad = false;
    else
        error('Invalid Input')
    end
    prompt = 'Want to plot overlay bars where embedded state changes occur? (y/n): ';
    pref = input(prompt, 's');
    if strcmp(pref,'y')
        prefChange = true;
        embeddedstateperformed = true; % Record that embedded states are found
    elseif strcmp(pref,'n')
        prefChange = false;
    else
        error('Invalid Input')
    end
end
%% Plot Power Data*******************************************************************
operativeremovalperformed = false; % Record that the adaptive log has not been
% removed of operative packets and adaptive states have not been extracted
if ~isempty(RawDataPower.PowerDomainData) && prefPower == true %If there is data in the JSON File and user wants to plot the data
    % Initialize variables
    NumberofChannels=size(RawDataPower.PowerDomainData(1).Bands,1);
    ChannelDataPower=cell(NumberofChannels,1);
    tvec = zeros(1,length(RawDataPower.PowerDomainData));
    if timing == true
    %plotting based off system tick**************************************************
        seconds = 0;
        % Determine corrective time offset-------------------------------------------
        tickref = RawDataPower.PowerDomainData(1).Header.systemTick - masterTick;
        timestampref = RawDataPower.PowerDomainData(1).Header.timestamp.seconds - masterTimeStamp;
        if timestampref > 6
            seconds = seconds + timestampref; % if time stamp differs by 7 or more seconds make correction
        elseif tickref < 0 && timestampref > 0
            seconds = seconds + rolloverseconds; % adds initial loop time if needed
        end
        %----------------------------------------------------------------------------
        for ii = 1:1:length(RawDataPower.PowerDomainData)
            if ii == 1 || RawDataPower.PowerDomainData(ii-1).Header.systemTick < RawDataPower.PowerDomainData(ii).Header.systemTick
                endtime = (RawDataPower.PowerDomainData(ii).Header.systemTick - masterTick)*0.0001 + endtime1 + seconds;
            else
                seconds = seconds + rolloverseconds;
                endtime = (RawDataPower.PowerDomainData(ii).Header.systemTick - masterTick)*0.0001 + endtime1 + seconds;
            end
            tvec(ii) = endtime;
            for i=1:NumberofChannels
                ChannelDataPower{i,1}= [ChannelDataPower{i,1}, RawDataPower.PowerDomainData(ii).Bands(i,:)];
            end
        end
    elseif timing == false
    %plotting based off packet gen times*********************************************
        jj = 0;
        for ii = 1:1:length(RawDataPower.PowerDomainData)
             if RawDataPower.PowerDomainData(ii).PacketGenTime > 0 % Check for Packet Gen Time
                jj = jj + 1;
                tvec(jj) = (RawDataPower.PowerDomainData(ii).PacketGenTime-FirstGoodTime)/1000;
                for i=1:NumberofChannels
                    ChannelDataPower{i,1}= [ChannelDataPower{i,1}, RawDataPower.PowerDomainData(ii).Bands(i,:)];
                end
             end  
        end
        if isnan(FirstGoodTime) % If Time Sync not enabled clear tvec
            tvec = [];
        end
    end      
    figure;
    if prefad == true
        h = subplot(5,1,[1 2]);
    end
    % Plot all bands in units related to the thresholds set--------------------------
    lasttimepoint = length(ChannelDataPower{1,1}); % When using Packet Gen Times the entire initialized time vector is not filled completely
    for i=1:NumberofChannels
        plot(tvec(1:lasttimepoint), ChannelDataPower{i,1},'DisplayName',['Band ',int2str(i)]);
        hold on
    end
    %--------------------------------------------------------------------------------
    if ~isempty(AdaptiveLog) && (prefChange == true || prefad == true)
        operativeremovalperformed = true; % Record that the adaptive log has been
        % removed of operative packets and adaptive states have been extracted
        operativelocs = [];
        adaptivestate = zeros(1,length(AdaptiveLog));
        adaptstate = 15; % set the first adaptive state to 15 indicating that no
        % adaptive therapy state is modifying therapy. This is used in operative mode
        % before the first operative packet is used.
        l = 0;
        for ii = 1:1:length(AdaptiveLog)
            if ~isfield(AdaptiveLog(ii).AdaptiveUpdate, 'Header') % Find locations of operative state changes
                l = l + 1;
                operativelocs(l) = ii;
                adaptstate = AdaptiveLog(ii).AdaptiveUpdate.CurrentAdaptiveState;
            else
                if AdaptiveLog(ii).AdaptiveUpdate.Header.info >= 128  % Embedded Mode
                    adaptivestate(1,ii) = AdaptiveLog(ii).AdaptiveUpdate.CurrentAdaptiveState;
                else % Operative Mode Hold State Since Previous
                    adaptivestate(1,ii) = adaptstate; % Holds state until next operative state change
                end
            end
        end
        l = 1;
        for ii = 1:length(operativelocs) % Remove any operative packets
            l = l - 1;
            AdaptiveLog(operativelocs(ii)+l) = [];
            adaptivestate = [adaptivestate(1,1:operativelocs(ii)-1+l),adaptivestate(1,operativelocs(ii)+1+l:end)];
        end
    end
    if prefChange == true && ~isempty(AdaptiveLog) % add bars where state change occurs
       % Initialize variables
        x = 1;
        y = 1;
        z = 1;
        statechange = [];
        secondschange = [];
        statechangetimes = [];
        seconds = 0;
        embeddedON = [];
        embeddedOFF = [];
        secondsembeddedOFF = [];
        embeddedOFFtimes = [];
        % Determine corrective time offset-------------------------------------------
        tickref = AdaptiveLog(1).AdaptiveUpdate.Header.systemTick - masterTick;
        timestampref = AdaptiveLog(1).AdaptiveUpdate.Header.timestamp.seconds - masterTimeStamp;
        if timestampref > 6
            seconds = seconds + timestampref; % if time stamp differs by 7 or more seconds make correction
        elseif tickref < 0 && timestampref > 0
            seconds = seconds + rolloverseconds; % adds initial loop time if needed
        end
        %----------------------------------------------------------------------------
        for i = 2:length(AdaptiveLog)
            if (AdaptiveLog(i).AdaptiveUpdate.Header.info >= 128) && (AdaptiveLog(i-1).AdaptiveUpdate.Header.info < 128)  % Embedded Mode Turned On
                embeddedON(y) = x;
                y = y + 1;
            end
            if AdaptiveLog(i-1).AdaptiveUpdate.Header.systemTick > AdaptiveLog(i).AdaptiveUpdate.Header.systemTick
                seconds = seconds + rolloverseconds;
            end
            if AdaptiveLog(i).AdaptiveUpdate.Header.info >= 128  % Embedded Mode
                if AdaptiveLog(i).AdaptiveUpdate.CurrentAdaptiveState ~= AdaptiveLog(i-1).AdaptiveUpdate.CurrentAdaptiveState
                    if timing == true %plotting based off system tick********************
                        statechange(x) = AdaptiveLog(i).AdaptiveUpdate.Header.systemTick;
                        secondschange(x) = seconds;
                        x = x+1;
                    elseif timing == false %plotting based off packet gen times**********
                        if AdaptiveLog(i).AdaptiveUpdate.PacketGenTime > 0 % Check for Packet Gen Time
                            statechange(x) = AdaptiveLog(i).AdaptiveUpdate.PacketGenTime;
                            x = x+1;
                        end
                    end
                end
            end
            if (AdaptiveLog(i).AdaptiveUpdate.Header.info < 128) && (AdaptiveLog(i-1).AdaptiveUpdate.Header.info >= 128)  % Embedded Mode Turned Off
                if timing == true %plotting based off system tick********************
                    embeddedOFF(z) = AdaptiveLog(i).AdaptiveUpdate.Header.systemTick;
                    secondsembeddedOFF(z) = seconds;
                    z = z + 1;
                elseif timing == false %plotting based off packet gen times**********
                    if AdaptiveLog(i).AdaptiveUpdate.PacketGenTime > 0 % Check for Packet Gen Time
                        embeddedOFF(z) = AdaptiveLog(i).AdaptiveUpdate.PacketGenTime;
                        z = z + 1;
                    end
                end
            end
        end
        for i = 1:length(statechange)
            if timing == true %plotting based off system tick************************
                statechangetimes(i) = (statechange(i) - masterTick)*0.0001 + endtime1 + secondschange(i);
            elseif timing == false %plotting based off packet gen times**************
                statechangetimes(i) = (statechange(i)-FirstGoodTime)/1000-1/(2*SampleRate) + endtime1;
            end
            if i == 1 % add legend entry
                line([statechangetimes(i) statechangetimes(i)], get(gca, 'ylim'),'LineWidth',2,'Color','r','DisplayName','State Change');
            else % don't add legend entry
                nextline = line([statechangetimes(i) statechangetimes(i)], get(gca, 'ylim'),'LineWidth',2,'Color','r');
                nextline.Annotation.LegendInformation.IconDisplayStyle = 'off';
            end
            hold on
        end
        hold off
        title('Power Data Output')
        legend('show')
        ylabel('Power (LSB)')
    elseif prefChange == false || isempty(AdaptiveLog)
        hold off
        title('Power Data Output')
        legend('show')
        ylabel('Power (LSB)')
        if isempty(AdaptiveLog)
            disp('AdaptiveLog is empty. Only Power Data can be plotted.')
        end
    end
    if prefad == true && ~isempty(AdaptiveLog)
        ProgramAmps = zeros(4,length(AdaptiveLog));
        StimRate = zeros(1,length(AdaptiveLog));
        tvecadapt = zeros(1,length(AdaptiveLog));
        seconds1 = 0;
        % Determine corrective time offset-------------------------------------------
        tickref = AdaptiveLog(1).AdaptiveUpdate.Header.systemTick - masterTick;
        timestampref = AdaptiveLog(1).AdaptiveUpdate.Header.timestamp.seconds - masterTimeStamp;
        if timestampref > 6
            seconds1 = seconds1 + timestampref;
        elseif tickref < 0 && timestampref > 0
            seconds1 = seconds1 + rolloverseconds;
        end
        %----------------------------------------------------------------------------
        for i = 1:length(AdaptiveLog)
            if timing == true
                if i == 1 || AdaptiveLog(i-1).AdaptiveUpdate.Header.systemTick < AdaptiveLog(i).AdaptiveUpdate.Header.systemTick
                    endtime = (AdaptiveLog(i).AdaptiveUpdate.Header.systemTick - masterTick)*0.0001 + endtime1 + seconds1;
                else
                    seconds1 = seconds1 + rolloverseconds;
                    endtime = (AdaptiveLog(i).AdaptiveUpdate.Header.systemTick - masterTick)*0.0001 + endtime1 + seconds1;
                end
                tvecadapt(i) = endtime;
                ProgramAmps(:,i) = AdaptiveLog(i).AdaptiveUpdate.CurrentProgramAmplitudesInMilliamps;
                StimRate(1,i) = AdaptiveLog(i).AdaptiveUpdate.StimRateInHz;
            else
                if AdaptiveLog(i).AdaptiveUpdate.PacketGenTime > 0 % Check for Packet Gen Time
                    endtime = (AdaptiveLog(i).AdaptiveUpdate.PacketGenTime-FirstGoodTime)/1000;
                    tvecadapt(i) = endtime;
                    ProgramAmps(:,i) = AdaptiveLog(i).AdaptiveUpdate.CurrentProgramAmplitudesInMilliamps;
                    StimRate(1,i) = AdaptiveLog(i).AdaptiveUpdate.StimRateInHz;
                end
            end
        end
        h1 = subplot(5,1,3);
        plot(tvecadapt,StimRate);
        title('Stim Rate')
        ylabel('Rate (Hz)')
        h2 = subplot(5,1,4);
        for i = 1:4
            plot(tvecadapt,ProgramAmps(i,:));
            hold on
        end
        title('Program Amplitude')
        ylabel('Amplitude (mA)')
        legend('Program 0','Program 1', 'Program 2','Program 3')
        hold off
        h3 = subplot(5,1,5);
        plot(tvecadapt,adaptivestate,'DisplayName','Adaptive State');
        hold on
        for i = 1:length(embeddedON)
            if i == 1 % add legend entry
                line([statechangetimes(embeddedON(i)) statechangetimes(embeddedON(i))], get(gca, 'ylim'),'LineWidth',2,'Color','g','DisplayName','Embedded ON');
            else % don't add legend entry
                nextline = line([statechangetimes(embeddedON(i)) statechangetimes(embeddedON(i))], get(gca, 'ylim'),'LineWidth',2,'Color','g');
                nextline.Annotation.LegendInformation.IconDisplayStyle = 'off';
            end
            hold on
        end
        for i = 1:length(embeddedOFF)
            if timing == true %plotting based off system tick************************
                embeddedOFFtimes(i) = (embeddedOFF(i) - masterTick)*0.0001 + endtime1 + secondsembeddedOFF(i);
            elseif timing == false %plotting based off packet gen times**************
                embeddedOFFtimes(i) = (embeddedOFF(i)-FirstGoodTime)/1000-1/(2*SampleRate) + endtime1;
            end
            if i == 1 % add legend entry
                line([embeddedOFFtimes(i) embeddedOFFtimes(i)], get(gca, 'ylim'),'LineWidth',2,'Color','r','DisplayName','Embedded OFF');
            else % don't add legend entry
                nextline = line([embeddedOFFtimes(i) embeddedOFFtimes(i)], get(gca, 'ylim'),'LineWidth',2,'Color','r');
                nextline.Annotation.LegendInformation.IconDisplayStyle = 'off';
            end
            hold on
        end
        hold off
        title('Adaptive State')
        legend('show')
        xlabel('\bf Time (s) (all plots)')
        ylabel('State (#)')
        linkaxes([h, h1, h2, h3],'x')
    end
elseif isempty(RawDataPower.PowerDomainData) %Inform user that there is no data in the JSON File
    disp('No Power Data Available to Plot')
end
%% Get Adaptive User Preferences*****************************************************
prompt = 'Want to plot Adaptive data? (y/n): ';
pref = input(prompt, 's');
if strcmp(pref,'y')
    prefAdapt = true;
elseif strcmp(pref,'n')
    prefAdapt = false;
else
    error('Invalid Input')
end
if prefAdapt == true
    prompt = 'Want to plot overlay bars where embedded state changes occur? (y/n): ';
    pref = input(prompt, 's');
    if strcmp(pref,'y')
        prefChange2 = true;
    elseif strcmp(pref,'n')
        prefChange2 = false;
    else
        error('Invalid Input')
    end
end
%% Plot Adaptive Data****************************************************************
if ~isempty(AdaptiveLog) && prefAdapt == true %If there is data in the JSON File and user wants to plot the data
    if operativeremovalperformed == false % adaptive log has not been removed of
        % operative packets and adaptive states have not been extracted
        operativelocs = [];
        adaptivestate = zeros(1,length(AdaptiveLog));
        adaptstate = 15; % set the first adaptive state to 15 indicating that no
        % adaptive therapy state is modifying therapy. This is used in operative mode
        % before the first operative packet is used.
        l = 0;
        for ii = 1:1:length(AdaptiveLog)
            if ~isfield(AdaptiveLog(ii).AdaptiveUpdate, 'Header') % Find locations of operative state changes
                l = l + 1;
                operativelocs(l) = ii;
                adaptstate = AdaptiveLog(ii).AdaptiveUpdate.CurrentAdaptiveState;
            else
                if AdaptiveLog(ii).AdaptiveUpdate.Header.info >= 128  % Embedded Mode
                    adaptivestate(1,ii) = AdaptiveLog(ii).AdaptiveUpdate.CurrentAdaptiveState;
                else % Operative Mode Hold State Since Previous
                    adaptivestate(1,ii) = adaptstate; % Holds state until next operative state change
                end
            end
        end
        l = 1;
        for ii = 1:length(operativelocs) % Remove any operative packets
            l = l - 1;
            AdaptiveLog(operativelocs(ii)+l) = [];
            adaptivestate = [adaptivestate(1,1:operativelocs(ii)-1+l),adaptivestate(1,operativelocs(ii)+1+l:end)];
        end
    end
    % Initialize variables
    AdaptiveData=zeros(2,length(AdaptiveLog));
    tvec = zeros(1,length(AdaptiveLog));
    ProgramAmps = zeros(4,length(AdaptiveLog));
    StimRate = zeros(1,length(AdaptiveLog));
    lowthresh0LSB = zeros(1,length(AdaptiveLog));
    highthresh0LSB = zeros(1,length(AdaptiveLog));
    lowthresh1LSB = zeros(1,length(AdaptiveLog));
    highthresh1LSB = zeros(1,length(AdaptiveLog));
    if timing == true %plotting based off system tick********************************
        seconds = 0;
        % Determine corrective time offset-------------------------------------------
        tickref = AdaptiveLog(1).AdaptiveUpdate.Header.systemTick - masterTick;
        timestampref = AdaptiveLog(1).AdaptiveUpdate.Header.timestamp.seconds - masterTimeStamp;
        if timestampref > 6
            seconds = seconds + timestampref; % if time stamp differs by 7 or more seconds make correction
        elseif tickref < 0 && timestampref > 0
            seconds = seconds + rolloverseconds; % adds initial loop time if needed
        end
        %----------------------------------------------------------------------------
        for ii = 1:1:length(AdaptiveLog)
            if ii == 1 || AdaptiveLog(ii-1).AdaptiveUpdate.Header.systemTick < AdaptiveLog(ii).AdaptiveUpdate.Header.systemTick
                endtime = (AdaptiveLog(ii).AdaptiveUpdate.Header.systemTick - masterTick)*0.0001 + endtime1 + seconds;
            else
                seconds = seconds + rolloverseconds;
                endtime = (AdaptiveLog(ii).AdaptiveUpdate.Header.systemTick - masterTick)*0.0001 + endtime1 + seconds;
            end
            tvec(ii) = endtime;
            AdaptiveData(1,ii) = AdaptiveLog(ii).AdaptiveUpdate.Ld0Status.output/(2^AdaptiveLog(ii).AdaptiveUpdate.Ld0Status.fixedDecimalPoint);
            AdaptiveData(2,ii) = AdaptiveLog(ii).AdaptiveUpdate.Ld1Status.output/(2^AdaptiveLog(ii).AdaptiveUpdate.Ld1Status.fixedDecimalPoint);
            ProgramAmps(:,ii) = AdaptiveLog(ii).AdaptiveUpdate.CurrentProgramAmplitudesInMilliamps;
            StimRate(1,ii) = AdaptiveLog(ii).AdaptiveUpdate.StimRateInHz;
            lowthresh0LSB(1,ii) = AdaptiveLog(ii).AdaptiveUpdate.Ld0Status.lowThreshold/(2^AdaptiveLog(ii).AdaptiveUpdate.Ld0Status.fixedDecimalPoint);
            highthresh0LSB(1,ii) = AdaptiveLog(ii).AdaptiveUpdate.Ld0Status.highThreshold/(2^AdaptiveLog(ii).AdaptiveUpdate.Ld0Status.fixedDecimalPoint);
            lowthresh1LSB(1,ii) = AdaptiveLog(ii).AdaptiveUpdate.Ld1Status.lowThreshold/(2^AdaptiveLog(ii).AdaptiveUpdate.Ld1Status.fixedDecimalPoint);
            highthresh1LSB(1,ii) = AdaptiveLog(ii).AdaptiveUpdate.Ld1Status.highThreshold/(2^AdaptiveLog(ii).AdaptiveUpdate.Ld1Status.fixedDecimalPoint);
        end
    elseif timing == false %plotting based off packet gen times**********************
        for ii = 1:1:length(AdaptiveLog)
            if AdaptiveLog(ii).AdaptiveUpdate.PacketGenTime > 0 % Check for Packet Gen Time
                tvec(ii) = (AdaptiveLog(ii).AdaptiveUpdate.PacketGenTime-FirstGoodTime)/1000;
                AdaptiveData(1,ii) = AdaptiveLog(ii).AdaptiveUpdate.Ld0Status.output/(2^AdaptiveLog(ii).AdaptiveUpdate.Ld0Status.fixedDecimalPoint);
                AdaptiveData(2,ii) = AdaptiveLog(ii).AdaptiveUpdate.Ld1Status.output/(2^AdaptiveLog(ii).AdaptiveUpdate.Ld1Status.fixedDecimalPoint);
                ProgramAmps(:,ii) = AdaptiveLog(ii).AdaptiveUpdate.CurrentProgramAmplitudesInMilliamps;
                StimRate(1,ii) = AdaptiveLog(ii).AdaptiveUpdate.StimRateInHz;
                lowthresh0LSB(1,ii) = AdaptiveLog(ii).AdaptiveUpdate.Ld0Status.lowThreshold/(2^AdaptiveLog(ii).AdaptiveUpdate.Ld0Status.fixedDecimalPoint);
                highthresh0LSB(1,ii) = AdaptiveLog(ii).AdaptiveUpdate.Ld0Status.highThreshold/(2^AdaptiveLog(ii).AdaptiveUpdate.Ld0Status.fixedDecimalPoint);
                lowthresh1LSB(1,ii) = AdaptiveLog(ii).AdaptiveUpdate.Ld1Status.lowThreshold/(2^AdaptiveLog(ii).AdaptiveUpdate.Ld1Status.fixedDecimalPoint);
                highthresh1LSB(1,ii) = AdaptiveLog(ii).AdaptiveUpdate.Ld1Status.highThreshold/(2^AdaptiveLog(ii).AdaptiveUpdate.Ld1Status.fixedDecimalPoint);
            end
        end
    end
    figure;
    h = subplot(5,1,[1 2]);
    % Plot all LDs in units related to the thresholds set----------------------------
    for i = 1:2
        plot(tvec, AdaptiveData(i,:),'DisplayName',['LD ',int2str(i)]);
        hold on
    end
    % Plot dashed threshold lines----------------------------------------------------
    plot(tvec,lowthresh0LSB,'g--','DisplayName','LD0 Threshold 1');
    hold on
    plot(tvec,highthresh0LSB,'k--','DisplayName','LD0 Threshold 2');
    hold on
    plot(tvec,lowthresh1LSB,'g:','DisplayName','LD1 Threshold 1');
    hold on
    plot(tvec,highthresh1LSB,'k:','DisplayName','LD1 Threshold 2');
    hold on
    %--------------------------------------------------------------------------------
    if prefChange2 == true % add bars where state change occurs
        if embeddedstateperformed == false % if embedded states weren't found in the power plotting section
        % Initialize variables
        x = 1;
        y = 1;
        z = 1;
        statechange = [];
        secondschange = [];
        statechangetimes = [];
        seconds = 0;
        embeddedON = [];
        embeddedOFF = [];
        secondsembeddedOFF = [];
        embeddedOFFtimes = [];
        % Determine corrective time offset-------------------------------------------
        tickref = AdaptiveLog(1).AdaptiveUpdate.Header.systemTick - masterTick;
        timestampref = AdaptiveLog(1).AdaptiveUpdate.Header.timestamp.seconds - masterTimeStamp;
        if timestampref > 6
            seconds = seconds + timestampref; % if time stamp differs by 7 or more seconds make correction
        elseif tickref < 0 && timestampref > 0
            seconds = seconds + rolloverseconds; % adds initial loop time if needed
        end
        %----------------------------------------------------------------------------
        for i = 2:length(AdaptiveLog)
            if (AdaptiveLog(i).AdaptiveUpdate.Header.info >= 128) && (AdaptiveLog(i-1).AdaptiveUpdate.Header.info < 128)  % Embedded Mode Turned On
                embeddedON(y) = x;
                y = y + 1;
            end
            if AdaptiveLog(i-1).AdaptiveUpdate.Header.systemTick > AdaptiveLog(i).AdaptiveUpdate.Header.systemTick
                seconds = seconds + rolloverseconds;
            end
            if AdaptiveLog(i).AdaptiveUpdate.Header.info >= 128  % Embedded Mode
                if AdaptiveLog(i).AdaptiveUpdate.CurrentAdaptiveState ~= AdaptiveLog(i-1).AdaptiveUpdate.CurrentAdaptiveState
                    if timing == true %plotting based off system tick********************
                        statechange(x) = AdaptiveLog(i).AdaptiveUpdate.Header.systemTick;
                        secondschange(x) = seconds;
                        x = x+1;
                    elseif timing == false %plotting based off packet gen times**********
                        if AdaptiveLog(i).AdaptiveUpdate.PacketGenTime > 0 % Check for Packet Gen Time
                            statechange(x) = AdaptiveLog(i).AdaptiveUpdate.PacketGenTime;
                            x = x+1;
                        end
                    end
                end
            end
            if (AdaptiveLog(i).AdaptiveUpdate.Header.info < 128) && (AdaptiveLog(i-1).AdaptiveUpdate.Header.info >= 128)  % Embedded Mode Turned Off
                if timing == true %plotting based off system tick********************
                    embeddedOFF(z) = AdaptiveLog(i).AdaptiveUpdate.Header.systemTick;
                    secondsembeddedOFF(z) = seconds;
                    z = z + 1;
                elseif timing == false %plotting based off packet gen times**********
                    if AdaptiveLog(i).AdaptiveUpdate.PacketGenTime > 0 % Check for Packet Gen Time
                        embeddedOFF(z) = AdaptiveLog(i).AdaptiveUpdate.PacketGenTime;
                        z = z + 1;
                    end
                end
            end
        end
        end
        for i = 1:length(statechange)
            if timing == true %plotting based off system tick************************
                statechangetimes(i) = (statechange(i) - masterTick)*0.0001 + endtime1 + secondschange(i);
            elseif timing == false %plotting based off packet gen times**************
                statechangetimes(i) = (statechange(i)-FirstGoodTime)/1000-1/(2*SampleRate) + endtime1;
            end
            if i == 1 % add legend entry
                line([statechangetimes(i) statechangetimes(i)], get(gca, 'ylim'),'LineWidth',2,'Color','r','DisplayName','State Change');
            else % don't add legend entry
                nextline = line([statechangetimes(i) statechangetimes(i)], get(gca, 'ylim'),'LineWidth',2,'Color','r');
                nextline.Annotation.LegendInformation.IconDisplayStyle = 'off';
            end
            hold on
        end
        hold off
        title('Adaptive Data Output')
        legend('show')
        ylabel('Power (LSB)')
    end
    h1 = subplot(5,1,3);
    plot(tvec,StimRate);
    title('Stim Rate')
    ylabel('Rate (Hz)')
    h2 = subplot(5,1,4);
    for i = 1:4
        plot(tvec,ProgramAmps(i,:));
        hold on
    end
    title('Program Amplitude')
    ylabel('Amplitude (mA)')
    legend('Program 0','Program 1', 'Program 2','Program 3')
    hold off
    h3 = subplot(5,1,5);
    plot(tvec,adaptivestate,'DisplayName','Adaptive State');
    hold on
    for i = 1:length(embeddedON)
        if i == 1 % add legend entry
            line([statechangetimes(embeddedON(i)) statechangetimes(embeddedON(i))], get(gca, 'ylim'),'LineWidth',2,'Color','g','DisplayName','Embedded ON');
        else % don't add legend entry
            nextline = line([statechangetimes(embeddedON(i)) statechangetimes(embeddedON(i))], get(gca, 'ylim'),'LineWidth',2,'Color','g');
            nextline.Annotation.LegendInformation.IconDisplayStyle = 'off';
        end
        hold on
    end
    for i = 1:length(embeddedOFF)
        if timing == true %plotting based off system tick************************
            embeddedOFFtimes(i) = (embeddedOFF(i) - masterTick)*0.0001 + endtime1 + secondsembeddedOFF(i);
        elseif timing == false %plotting based off packet gen times**************
            embeddedOFFtimes(i) = (embeddedOFF(i)-FirstGoodTime)/1000-1/(2*SampleRate) + endtime1;
        end
        if i == 1 % add legend entry
            line([embeddedOFFtimes(i) embeddedOFFtimes(i)], get(gca, 'ylim'),'LineWidth',2,'Color','r','DisplayName','Embedded OFF');
        else % don't add legend entry
            nextline = line([embeddedOFFtimes(i) embeddedOFFtimes(i)], get(gca, 'ylim'),'LineWidth',2,'Color','r');
            nextline.Annotation.LegendInformation.IconDisplayStyle = 'off';
        end
        hold on
    end
    hold off
    title('Adaptive State')
    legend('show')
    xlabel('\bf Time (s) (all plots)')
    ylabel('State (#)')
    linkaxes([h, h1, h2, h3],'x')
elseif isempty(AdaptiveLog) %Inform user that there is no data in the JSON File
    disp('No Adaptive Data Available to Plot')
end
%% Get Accel User Preferences********************************************************
prompt = 'Want to plot Accel data? (y/n): ';
pref = input(prompt, 's');
if strcmp(pref,'y')
    prefAccel = true;
elseif strcmp(pref,'n')
    prefAccel = false;
else
    error('Invalid Input')
end
%% Plot Accelerometer Data***********************************************************
if ~isempty(RawDataAccel.AccelData) && prefAccel == true %If there is data in the JSON File and user wants to plot the data
    if RawDataAccel.AccelData(1).SampleRate==4 % Get accel sample rate
        SampleRateAccel=4; %Hz
    elseif RawDataAccel.AccelData(1).SampleRate==3
        SampleRateAccel=8;
    elseif RawDataAccel.AccelData(1).SampleRate==2
        SampleRateAccel=16;
    elseif RawDataAccel.AccelData(1).SampleRate==1
        SampleRateAccel=32;
    elseif RawDataAccel.AccelData(1).SampleRate==0
        SampleRateAccel=64;
    else
        disp('Error: undefined sampling rate')
    end
    %Necessary if running this section consectutively--------------------------------
    if exist('stpAccel','var')
        clear stpAccel
    end
    %--------------------------------------------------------------------------------
    NumberofChannels=3; %x,y,z
    ChannelDataAccel=cell(3,1);
    tvec = [];
    missedpacketgapsAccel = 0;
    seconds = 0; %Initializes seconds addition due to looping
    % Determine corrective time offset-----------------------------------------------
    tickref = RawDataAccel.AccelData(1).Header.systemTick - masterTick;
    timestampref = RawDataAccel.AccelData(1).Header.timestamp.seconds - masterTimeStamp;
    if timestampref > 6
        seconds = seconds + timestampref; % if time stamp differs by 7 or more seconds make correction
    elseif tickref < 0 && timestampref > 0
        seconds = seconds + rolloverseconds; % adds initial loop time if needed
    end
    %--------------------------------------------------------------------------------
    
    for ii = 1:1:length(RawDataAccel.AccelData)
        %Keep track of missed packets------------------------------------------------
        if ii ~= 1
            if RawDataAccel.AccelData(ii-1).Header.dataTypeSequence == 255
                if RawDataAccel.AccelData(ii).Header.dataTypeSequence ~= 0
                    missedpacketgapsAccel = missedpacketgapsAccel + 1;
                end
            else
                if RawDataAccel.AccelData(ii).Header.dataTypeSequence ~= RawDataAccel.AccelData(ii-1).Header.dataTypeSequence + 1
                    missedpacketgapsAccel = missedpacketgapsAccel + 1;
                end
            end
        end
        %----------------------------------------------------------------------------
        if timing == true %plotting based off system tick****************************
            if ii == 1
                endtimeAccel = (size(RawDataAccel.AccelData(ii).XSamples,1)-1)/SampleRateAccel;
                endtime = (RawDataAccel.AccelData(ii).Header.systemTick - masterTick)*0.0001 + endtimeAccel + seconds;
                endtimeold = endtime - endtimeAccel;
            else
                endtimeold = endtime;
                if RawDataAccel.AccelData(ii-1).Header.systemTick < RawDataAccel.AccelData(ii).Header.systemTick
                    endtime = (RawDataAccel.AccelData(ii).Header.systemTick - masterTick)*0.0001 + endtimeAccel + seconds;
                else
                    seconds = seconds + rolloverseconds;
                    endtime = (RawDataAccel.AccelData(ii).Header.systemTick - masterTick)*0.0001 + endtimeAccel + seconds;
                end
            end
            if spacing == true
                %linearly spacing data between packet system ticks-------------------
                if ii ~= 1
                    tvec = [tvec(1:end-1), linspace(endtimeold,endtime,size(RawDataAccel.AccelData(ii).XSamples,1)+1)];
                else
                    tvec = [tvec(1:end-1), linspace(endtimeold,endtime,size(RawDataAccel.AccelData(ii).XSamples,1))];
                end
            elseif spacing == false
                %sample rate spacing data between packet system ticks----------------
                tvec = [tvec, endtime-(size(RawDataAccel.AccelData(ii).XSamples,1)-1)/SampleRateAccel:1/SampleRateAccel:endtime];
            end
            %------------------------------------------------------------------------
            ChannelDataAccel{1,1}= [ChannelDataAccel{1,1}; RawDataAccel.AccelData(ii).XSamples(:,:)];
            ChannelDataAccel{2,1}= [ChannelDataAccel{2,1}; RawDataAccel.AccelData(ii).YSamples(:,:)];
            ChannelDataAccel{3,1}= [ChannelDataAccel{3,1}; RawDataAccel.AccelData(ii).ZSamples(:,:)];
        elseif timing == false %plotting based off packet gen times******************
            if RawDataAccel.AccelData(ii).PacketGenTime > 0 % Check for Packet Gen Time
                if spacing == true
                    %linearly spacing data between packet gen times------------------
                    tvec = [tvec, linspace((RawDataAccel.AccelData(ii).PacketGenTime-FirstGoodTime)/1000,(RawDataAccel.AccelData(ii).PacketGenTime-FirstGoodTime)/1000+(size(RawDataAccel.AccelData(ii).XSamples,1)-1)/SampleRateAccel,size(RawDataAccel.AccelData(1).XSamples,1))];
                elseif spacing == false
                    %sample rate spacing data between packet gen times---------------
                    if ~exist('stpAccel','var')
                        stpAccel = 1;
                        endtimeAccel = (size(RawDataAccel.AccelData(ii).XSamples,1)-1)/SampleRateAccel;
                        endtime = endtimeAccel;
                    end
                    endtime = (RawDataAccel.AccelData(ii).PacketGenTime-FirstGoodTime)/1000 + endtimeAccel;
                    tvec = [tvec, endtime-(size(RawDataAccel.AccelData(ii).XSamples,1)-1)/SampleRateAccel:1/SampleRateAccel:endtime];
                end
                %--------------------------------------------------------------------
                ChannelDataAccel{1,1}= [ChannelDataAccel{1,1}; RawDataAccel.AccelData(ii).XSamples(:,:)];
                ChannelDataAccel{2,1}= [ChannelDataAccel{2,1}; RawDataAccel.AccelData(ii).YSamples(:,:)];
                ChannelDataAccel{3,1}= [ChannelDataAccel{3,1}; RawDataAccel.AccelData(ii).ZSamples(:,:)];
            end
        end
        %****************************************************************************
    end
    figure,
    for i=1:NumberofChannels
        plot(tvec, ChannelDataAccel{i,1}')
        hold on
    end
    hold off
    title('Accelerometer Output')
    legend('X', 'Y', 'Z')
    xlabel('Time (s)')
    ylabel('Accel (centigees)')
elseif isempty(RawDataAccel.AccelData) %Inform user that there is no data in the JSON File
    disp('No Accel Data Available to Plot')
end