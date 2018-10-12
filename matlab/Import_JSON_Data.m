%--------------------------------------------------------------------------
% Copyright (c) Medtronic, Inc. 2017
%
% MEDTRONIC CONFIDENTIAL -- This document is the property of Medtronic
% PLC, and must be accounted for. Information herein is confidential trade
% secret information. Do not reproduce it, reveal it to unauthorized 
% persons, or send it outside Medtronic without proper authorization.
%--------------------------------------------------------------------------
%
% File Name: Import_JSON_Data.m
% Autor: Ben Johnson (johnsb68)
%
% Description: This file contains the MATLAB script for read in the JSON files. 
% This script is sectioned to allow step by step evaluation using 
% the "Run and Advance" or "Run Section" MATLAB feature. Note that if the whole 
% script is executed at once then the session will be automatically closed.
%
% -------------------------------------------------------------------------
%% Get JSON Files of Interest********************************************************
function [AdaptiveLog,DeviceSettings,DiagnosticsLog,ErrorLog,EventLog,RawDataAccel...
    ,RawDataFFT,RawDataPower,RawDataTD,StimLog,TimeSync] = Import_JSON_Data()
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
end